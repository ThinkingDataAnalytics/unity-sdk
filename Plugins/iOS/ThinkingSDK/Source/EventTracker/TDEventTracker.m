//
//  TAEventTracker.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TDEventTracker.h"
#import "TDAnalyticsNetwork.h"
#import "TDEventRecord.h"
#import "TDConfigPrivate.h"

#if TARGET_OS_IOS

#if __has_include(<ThinkingDataCore/TDNetworkReachability.h>)
#import <ThinkingDataCore/TDNetworkReachability.h>
#else
#import "TDNetworkReachability.h"
#endif

#endif

static dispatch_queue_t td_networkQueue;
static NSUInteger const kBatchSize = 50;
static NSURLSessionTask *g_currentTask = nil;

@interface TDEventTracker ()
@property (atomic, strong) TDAnalyticsNetwork *network;
@property (atomic, strong) TDConfig *config;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) TDSqliteDataQueue *dataQueue;
@property (atomic, assign) BOOL networkProcessing;

@end

@implementation TDEventTracker

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"cn.thinkingdata.%p", (void *)self];
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        td_networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)td_networkQueue {
    return td_networkQueue;
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue instanceToken:(nonnull NSString *)instanceToken {
    if (self = [self init]) {
        self.queue = queue;
        self.config = [ThinkingAnalyticsSDK instanceWithAppid:instanceToken].config;
        self.network = [self generateNetworkWithConfig:self.config];
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:[self.config innerGetMapInstanceToken]];
    }
    return self;
}

- (TDAnalyticsNetwork *)generateNetworkWithConfig:(TDConfig *)config {
    TDAnalyticsNetwork *network = [[TDAnalyticsNetwork alloc] init];
    network.appid = config.appid;
    network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
    network.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sync", config.serverUrl]];
    network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug", config.serverUrl]];
    network.securityPolicy = config.securityPolicy;
    return network;
}

//MARK: - Public

- (void)track:(NSDictionary *)event immediately:(BOOL)immediately saveOnly:(BOOL)isSaveOnly {
    TDMode mode = self.config.mode;
    NSInteger count = 0;
    if (mode == TDModeDebugOnly || mode == TDModeDebug) {

        if (isSaveOnly) {
            return;
        }
        TDLogInfo(@"Enqueue data: %@", event);
        dispatch_async(self.queue, ^{
            dispatch_async(td_networkQueue, ^{
                [self flushDebugEvent:event];
            });
        });
        // TDModeDebug Mode After the data is sent, it will still be stored locally, so it is necessary to query the database data to determine whether the number of records is sufficient for uploading
        @synchronized (TDSqliteDataQueue.class) {
            count = [self.dataQueue sqliteCountForAppid:[self.config innerGetMapInstanceToken]];
        }
    } else {
        if (immediately) {

            if (isSaveOnly) {
                return;
            }
            TDLogInfo(@"Enqueue data: %@", event);
            dispatch_async(self.queue, ^{
                dispatch_async(td_networkQueue, ^{
                    [self flushImmediately:event];
                });
            });
        } else {
            TDLogInfo(@"Enqueue data: %@", event);
            count = [self saveEventsData:event];
        }
    }
    if (count >= [self.config.uploadSize integerValue]) {

        if (isSaveOnly) {
            return;
        }
        TDLogInfo(@"SDK flush success. The cache is full. count: %ld, uploadSize: %d", count, [self.config.uploadSize integerValue]);
        [self flush];
    }
}

- (void)trackDebugEvent:(NSDictionary *)event {
    dispatch_async(self.queue, ^{
        dispatch_async(td_networkQueue, ^{
            [self.network flushDebugEvents:event appid:self.config.appid isDebugOnly:YES];
        });
    });
}

- (void)flushImmediately:(NSDictionary *)event {
    TDLogInfo(@"SDK flush success. Immediately.");
    [self.network flushEvents:@[event]];
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count = 0;
    @synchronized (TDSqliteDataQueue.class) {

        if (self.config.innerEnableEncrypt) {
#if TARGET_OS_IOS
            NSDictionary *encryptData = [[ThinkingAnalyticsSDK instanceWithAppid:[self.config innerGetMapInstanceToken]].encryptManager encryptJSONObject:event];
            if (encryptData == nil) {
                encryptData = event;
            }
            count = [self.dataQueue addObject:encryptData withAppid:[self.config innerGetMapInstanceToken]];
#elif TARGET_OS_OSX
            count = [self.dataQueue addObject:event withAppid:[self.config innerGetMapInstanceToken]];
#endif
        } else {
            count = [self.dataQueue addObject:event withAppid:[self.config innerGetMapInstanceToken]];
        }
    }
    return count;
}

- (void)flushDebugEvent:(NSDictionary *)event {
    if (self.config.mode == TDModeDebug || self.config.mode == TDModeDebugOnly) {
        BOOL isDebugOnly = self.config.mode == TDModeDebugOnly;
        int debugResult = [self.network flushDebugEvents:event appid:self.config.appid isDebugOnly:isDebugOnly];
        if (debugResult == -1) {
            // Downgrade
            if (self.config.mode == TDModeDebug) {
                dispatch_async(self.queue, ^{
                    [self saveEventsData:event];
                });
            } else if (self.config.mode == TDModeDebugOnly) {
                TDLogDebug(@"The data will be discarded due to this device is not allowed to debug:%@", event);
            }
            self.config.mode = TDModeNormal;
        }
        else if (debugResult == -2) {
            TDLogDebug(@"Exception occurred when sending message to Server:%@", event);
            if (self.config.mode == TDModeDebug) {
                
                dispatch_async(self.queue, ^{
                    [self saveEventsData:event];
                });
            }
        }
    } else {
        
        NSInteger count = [self saveEventsData:event];
        if (count >= [self.config.uploadSize integerValue]) {
            [self flush];
        }
    }
}

- (void)flush {
    [self _asyncWithCompletion:^{}];
}

/// Synchronize data asynchronously (synchronize data in the local database to TA)
/// Need to add this event to the serialQueue queue
/// In some scenarios, event warehousing and sending network requests happen at the same time. Event storage is performed in serialQueue, and data reporting is performed in networkQueue. To ensure that events are stored first, you need to add the reported data operation to serialQueue
- (void)_asyncWithCompletion:(void(^)(void))completion {
    if (self.networkProcessing) {
        return;
    }
    
    void(^block)(void) = ^{
        dispatch_async(td_networkQueue, ^{
            [self _syncWithSize:kBatchSize completion:completion];
        });
    };
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(self.queue)) {
        block();
    } else {
        dispatch_async(self.queue, block);
    }    
}

/// Synchronize data (synchronize the data in the local database to TA)
/// @param size The maximum number of items obtained from the database each time, the default is 50
/// @param completion synchronous callback
/// This method needs to be performed in networkQueue, and will continue to send network requests until the data in the database is sent
- (void)_syncWithSize:(NSUInteger)size completion:(void(^)(void))completion {
#if TARGET_OS_IOS
    NSString *networkType = [[TDNetworkReachability shareInstance] networkState];
    if (!([self convertNetworkType:networkType] & [self.config getNetworkType])) {
        if (completion) {
            completion();
        }
        return;
    }
#endif
    
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodIds;
    NSArray *uuids;
    @synchronized (TDSqliteDataQueue.class) {
        
        NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config innerGetMapInstanceToken]];
        NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
        NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        for (TDEventRecord *record in encryptRecords) {
            [indexs addObject:record.index];
            [recordContents addObject:record.event];
        }
        recodIds = indexs;
        recordArray = recordContents;
        
        
        uuids = [self.dataQueue upadteRecordIds:recodIds];
    }
     
    
    if (recordArray.count == 0 || uuids.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    self.networkProcessing = YES;

    BOOL flushSucc = YES;
    int _maxStackCount = 0;
    while (recordArray.count > 0 && uuids.count > 0 && flushSucc && _maxStackCount <= 100) {
        @autoreleasepool {
            flushSucc = [self.network flushEvents:recordArray];
            if (flushSucc) {
                @synchronized (TDSqliteDataQueue.class) {
                    _maxStackCount ++;
                    BOOL ret = [self.dataQueue removeDataWithuids:uuids];
                    if (!ret) {
                        break;
                    }
                    
                    NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config innerGetMapInstanceToken]];
                    NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
                    NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                    NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                    for (TDEventRecord *record in encryptRecords) {
                        [indexs addObject:record.index];
                        [recordContents addObject:record.event];
                    }
                    recodIds = indexs;
                    recordArray = recordContents;
                    
                    
                    uuids = [self.dataQueue upadteRecordIds:recodIds];
                }
            } else {
                _maxStackCount = 0;
                break;
            }
        }
    }
    if (completion) {
        completion();
    }
    
    self.networkProcessing = NO;
}

- (NSArray<TDEventRecord *> *)encryptEventRecords:(NSArray<TDEventRecord *> *)records {
#if TARGET_OS_IOS
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    
    TDEncryptManager *encryptManager = [ThinkingAnalyticsSDK instanceWithAppid:[self.config innerGetMapInstanceToken]].encryptManager;
    
    if (self.config.innerEnableEncrypt && encryptManager.isValid) {
        for (TDEventRecord *record in records) {
            
            if (record.encrypted) {
                
                [encryptRecords addObject:record];
            } else {
                
                NSDictionary *obj = [encryptManager encryptJSONObject:record.event];
                if (obj) {
                    [record setSecretObject:obj];
                    [encryptRecords addObject:record];
                } else {
                    [encryptRecords addObject:record];
                }
            }
        }
        return encryptRecords.count == 0 ? records : encryptRecords;
    } else {
        return records;
    }
#elif TARGET_OS_OSX
    return records;
#endif
}

- (void)syncSendAllData {
    dispatch_sync(td_networkQueue, ^{});
}

- (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return ThinkingNetworkTypeALL;
    } else if ([@"WIFI" isEqualToString:networkType]) {
        return ThinkingNetworkTypeWIFI;
    } else if ([@"2G" isEqualToString:networkType]) {
        return ThinkingNetworkType2G;
    } else if ([@"3G" isEqualToString:networkType]) {
        return ThinkingNetworkType3G;
    } else if ([@"4G" isEqualToString:networkType]) {
        return ThinkingNetworkType4G;
    }else if([@"5G"isEqualToString:networkType])
    {
        return ThinkingNetworkType5G;
    }
    return ThinkingNetworkTypeNONE;
}

//MARK: - Setter & Getter


@end
