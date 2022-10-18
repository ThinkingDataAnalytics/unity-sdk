//
//  TAAppExtensionAnalytic.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/5/25.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TAAppExtensionAnalytic.h"
#import "TAAppExtensionAnalyticConfig.h"

#if __has_include(<ThinkingSDK/TDCalibratedTimeWithNTP.h>)
#import <ThinkingSDK/TDCalibratedTimeWithNTP.h>
#else
#import "TDCalibratedTimeWithNTP.h"
#endif

#if __has_include(<ThinkingSDK/TDCalibratedTime.h>)
#import <ThinkingSDK/TDCalibratedTime.h>
#else
#import "TDCalibratedTime.h"
#endif


NSString * const kTAAppExtensionEventName = @"ta_app_extension_event_name";
NSString * const kTAAppExtensionEventProperties = @"ta_app_extension_properties";
NSString * const kTAAppExtensionTime = @"time";
NSString * const kTAAppExtensionEventPropertiesSource = @"from_app_extension";

@interface TAAppExtensionAnalytic()
@property (nonatomic, strong) TAAppExtensionAnalyticConfig *config;

@end

/// 用于标记队列
void *TAAppExtensionQueueTag = &TAAppExtensionQueueTag;

/// 多实例对象的容器
static NSMutableDictionary<NSString *, TAAppExtensionAnalytic *> *_instances;
/// 事件采集队列
static dispatch_queue_t _appExtensionQueue;
/// 时间校准工具
static TDCalibratedTime *_calibrateTimeManage;

@implementation TAAppExtensionAnalytic

//MARK: - Public Methods

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instances = [NSMutableDictionary dictionary];
        
        _appExtensionQueue = dispatch_queue_create("cn.thinkingdata.appExtensionQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(_appExtensionQueue, TAAppExtensionQueueTag, &TAAppExtensionQueueTag, NULL);
    });
}

+ (TAAppExtensionAnalytic *)analyticWithInstanceName:(NSString * _Nonnull)instanceName appGroupId:(NSString * _Nonnull)appGroupId {
    @synchronized (self) {
        TAAppExtensionAnalyticConfig *config = [[TAAppExtensionAnalyticConfig alloc] init];
        config.instanceName = instanceName;
        config.appGroupId = appGroupId;
        TAAppExtensionAnalytic *analytic = [self analyticWithConfig:config];
        return analytic;
    }
}

+ (TAAppExtensionAnalytic *)analyticWithConfig:(TAAppExtensionAnalyticConfig *)config {
    @synchronized (self) {
        if (![config.instanceName isKindOfClass:NSString.class] || !config.instanceName.length) {
            return nil;
        }
        if (![config.appGroupId isKindOfClass:NSString.class] || !config.appGroupId.length) {
            return nil;
        }
        if (_instances[config.instanceName]) {
            return _instances[config.instanceName];
        } else {
            TAAppExtensionAnalytic *analytic = [[TAAppExtensionAnalytic alloc] init];
            analytic.config = config;
            _instances[config.instanceName] = analytic;
            return analytic;
        }
    }
}

+ (void)calibrateTime:(NSTimeInterval)timestamp {
    _calibrateTimeManage = [TDCalibratedTime sharedInstance];
    [[TDCalibratedTime sharedInstance] recalibrationWithTimeInterval:timestamp/1000.];
}

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer {
    if ([ntpServer isKindOfClass:[NSString class]] && ntpServer.length > 0) {
        _calibrateTimeManage = [TDCalibratedTimeWithNTP sharedInstance];
        [[TDCalibratedTimeWithNTP sharedInstance] recalibrationWithNtps:@[ntpServer]];
    }
}

- (BOOL)writeEvent:(NSString *)eventName properties:(NSDictionary *)properties {
    @try {
        if (![eventName isKindOfClass:NSString.class] || !eventName.length) {
            return NO;
        }
        // 如果不为空，但是不是字典类型，就返回NO
        if (properties && ![properties isKindOfClass:NSDictionary.class]) {
            return NO;
        }
        
        NSMutableDictionary *mutableProperties = [NSMutableDictionary dictionaryWithDictionary:properties];
        mutableProperties[kTAAppExtensionEventPropertiesSource] = @(true);

        __block BOOL result = NO;
        dispatch_block_t block = ^{
            NSDictionary *event = @{
                kTAAppExtensionEventName: eventName,
                kTAAppExtensionEventProperties: mutableProperties,
                kTAAppExtensionTime: [self calibrateDate:[NSDate date]],
            };
            NSString *path = [self filePathForApplicationGroup];
            if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                NSDictionary *attributes = nil;
#if TARGET_OS_IOS
                attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
#endif
                [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:attributes];
            }
            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
            if (mutableArray.count) {
                [mutableArray addObject:event];
            } else {
                mutableArray = [NSMutableArray arrayWithObject:event];
            }
            NSError *err = NULL;
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:mutableArray format:NSPropertyListBinaryFormat_v1_0 options:0 error:&err];
            if (path.length && data.length) {
                result = [data  writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        };
        if (dispatch_get_specific(TAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(_appExtensionQueue, block);
        }
        return result;
    } @catch (NSException *exception) {
        return NO;
    }
}

- (NSArray *)readAllEvents {
    @try {
        __block NSArray *dataArray = @[];
        dispatch_block_t block = ^() {
            NSString *path = [self filePathForApplicationGroup];
            NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
            dataArray = array;
        };
        if (dispatch_get_specific(TAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(_appExtensionQueue, block);
        }
        return dataArray;
    } @catch (NSException *exception) {
        return @[];
    }
}

- (BOOL)deleteEvents {
    @try {
        __block BOOL result = NO;
        dispatch_block_t block = ^{
            NSString *path = [self filePathForApplicationGroup];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            NSData *data= [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
            if (path.length && data.length) {
                result = [data writeToFile:path options:NSDataWritingAtomic error:nil];
            }
        };
        if (dispatch_get_specific(TAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(_appExtensionQueue, block);
        }
        return result ;
    } @catch (NSException *exception) {
        return NO;
    }
}

//MARK: - Private Methods

/// 返回对应 Extension 的数据缓存路径
- (NSString *)filePathForApplicationGroup {
    @try {
        __block NSString *filePath = nil;
        dispatch_block_t block = ^() {
            NSString *fileName = [NSString stringWithFormat:@"thinking_data_events_%@.plist", self.config.instanceName];
            NSURL *pathUrl = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:self.config.appGroupId] URLByAppendingPathComponent:fileName];
            filePath = pathUrl.path;
        };
        if (dispatch_get_specific(TAAppExtensionQueueTag)) {
            block();
        } else {
            dispatch_sync(_appExtensionQueue, block);
        }
        return filePath;
    } @catch (NSException *exception) {
        return nil;
    }
}

/// 校准时间
/// @param date 目标时间
/// @return 校准后的时间
- (NSDate *)calibrateDate:(NSDate *)date {
    if (_calibrateTimeManage && !_calibrateTimeManage.stopCalibrate) {
        NSTimeInterval systemUptime = [[NSProcessInfo processInfo] systemUptime];
        NSTimeInterval outTime = systemUptime - _calibrateTimeManage.systemUptime;
        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(_calibrateTimeManage.serverTime + outTime)];
        return serverDate;
    }
    return date;
}

@end
