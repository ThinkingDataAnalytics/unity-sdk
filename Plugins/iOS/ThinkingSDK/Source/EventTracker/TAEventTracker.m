//
//  TAEventTracker.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TAEventTracker.h"
#import "TANetwork.h"
#import "TAReachability.h"
#import "TDEventRecord.h"

static dispatch_queue_t td_networkQueue;

@interface TAEventTracker ()
@property (atomic, strong) TANetwork *network;
@property (atomic, strong) TDConfig *config;
@property (atomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) TDSqliteDataQueue *dataQueue;

@end

@implementation TAEventTracker

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
        self.config = [ThinkingAnalyticsSDK sharedInstanceWithAppid:instanceToken].config;
        self.network = [self generateNetworkWithConfig:self.config];
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:[self.config getMapInstanceToken]];
    }
    return self;
}

- (TANetwork *)generateNetworkWithConfig:(TDConfig *)config {
    TANetwork *network = [[TANetwork alloc] init];
    network.debugMode = config.debugMode;
    network.appid = config.appid;
    network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
    network.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sync", config.configureURL]];
    network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug", config.configureURL]];
    network.securityPolicy = config.securityPolicy;
    return network;
}

//MARK: - Public

- (void)track:(NSDictionary *)event immediately:(BOOL)immediately saveOnly:(BOOL)isSaveOnly {
    ThinkingAnalyticsDebugMode debugMode = self.config.debugMode;
    NSInteger count = 0;
    if (debugMode == ThinkingAnalyticsDebugOnly || debugMode == ThinkingAnalyticsDebug) {
        
        if (isSaveOnly) {
            return;
        }
        TDLogDebug(@"queueing debug data: %@", event);
        dispatch_async(self.queue, ^{
            dispatch_async(td_networkQueue, ^{
                [self flushDebugEvent:event];
            });
        });
        // ThinkingAnalyticsDebug Mode After the data is sent, it will still be stored locally, so it is necessary to query the database data to determine whether the number of records is sufficient for uploading
        @synchronized (TDSqliteDataQueue.class) {
            count = [self.dataQueue sqliteCountForAppid:[self.config getMapInstanceToken]];
        }
    } else {
        if (immediately) {
            
            if (isSaveOnly) {
                return;
            }
            TDLogDebug(@"queueing data flush immediately:%@", event);
            dispatch_async(self.queue, ^{
                dispatch_async(td_networkQueue, ^{
                    [self flushImmediately:event];
                });
            });
        } else {
            TDLogDebug(@"queueing data:%@", event);
            count = [self saveEventsData:event];
        }
    }
    if (count >= [self.config.uploadSize integerValue]) {
        
        if (isSaveOnly) {
            return;
        }
        TDLogDebug(@"flush action, count: %ld, uploadSize: %d",count, [self.config.uploadSize integerValue]);
        [self flush];
    }
}

- (void)flushImmediately:(NSDictionary *)event {
    [self.network flushEvents:@[event]];
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count = 0;
    @synchronized (TDSqliteDataQueue.class) {
        
        if (_config.enableEncrypt) {
#if TARGET_OS_IOS
            NSDictionary *encryptData = [[ThinkingAnalyticsSDK sharedInstanceWithAppid:self.config.appid].encryptManager encryptJSONObject:event];
            if (encryptData == nil) {
                encryptData = event;
            }
            count = [self.dataQueue addObject:encryptData withAppid:[self.config getMapInstanceToken]];
#elif TARGET_OS_OSX
            count = [self.dataQueue addObject:event withAppid:[self.config getMapInstanceToken]];
#endif
        } else {
            count = [self.dataQueue addObject:event withAppid:[self.config getMapInstanceToken]];
        }
    }
    return count;
}

- (void)flushDebugEvent:(NSDictionary *)event {
    if (self.config.debugMode == ThinkingAnalyticsDebug || self.config.debugMode == ThinkingAnalyticsDebugOnly) {
        int debugResult = [self.network flushDebugEvents:event withAppid:self.config.appid];
        if (debugResult == -1) {
            // Downgrade
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                dispatch_async(self.queue, ^{
                    [self saveEventsData:event];
                });
                
                self.config.debugMode = ThinkingAnalyticsDebugOff;
                self.network.debugMode = ThinkingAnalyticsDebugOff;
            } else if (self.config.debugMode == ThinkingAnalyticsDebugOnly) {
                TDLogDebug(@"The data will be discarded due to this device is not allowed to debug:%@", event);
            }
        }
        else if (debugResult == -2) {
            TDLogDebug(@"Exception occurred when sending message to Server:%@", event);
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                
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
    
    
    NSString *networkType = [[TAReachability shareInstance] networkState];
    if (!([TAReachability convertNetworkType:networkType] & self.config.networkTypePolicy)) {
        if (completion) {
            completion();
        }
        return;
    }
    
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodIds;
    NSArray *uuids;
    @synchronized (TDSqliteDataQueue.class) {
        
        NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config getMapInstanceToken]];
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
    
    
    
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && uuids.count > 0 && flushSucc) {
        flushSucc = [self.network flushEvents:recordArray];
        if (flushSucc) {
            @synchronized (TDSqliteDataQueue.class) {
                BOOL ret = [self.dataQueue removeDataWithuids:uuids];
                if (!ret) {
                    break;
                }
                
                NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self.config getMapInstanceToken]];
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
            break;
        }
    }
    if (completion) {
        completion();
    }
}

- (NSArray<TDEventRecord *> *)encryptEventRecords:(NSArray<TDEventRecord *> *)records {
#if TARGET_OS_IOS
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    
    TDEncryptManager *encryptManager = [ThinkingAnalyticsSDK sharedInstanceWithAppid:[self.config getMapInstanceToken]].encryptManager;
    
    if (self.config.enableEncrypt && encryptManager.isValid) {
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


//MARK: - Setter & Getter


@end
