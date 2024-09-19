//
//  TDAnalyticsModule.m
//  ThinkingSDK.default-TDCore-iOS
//
//  Created by 杨雄 on 2023/7/2.
//

#import "TDAnalyticsModule.h"
#import "ThinkingAnalyticsSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"

#if TARGET_OS_IOS
#import "TDPushClickEvent.h"
#endif

#import "TDUserEventSet.h"

//MARK: router
#if __has_include(<ThinkingDataCore/TAAnnotation.h>)
#import <ThinkingDataCore/TAAnnotation.h>
#else
#import "TAAnnotation.h"
#endif
#if __has_include(<ThinkingDataCore/TAModuleProtocol.h>)
#import <ThinkingDataCore/TAModuleProtocol.h>
#else
#import "TAModuleProtocol.h"
#endif
#if __has_include(<ThinkingDataCore/TAContext.h>)
#import <ThinkingDataCore/TAContext.h>
#else
#import "TAContext.h"
#endif

static NSString * const kTDPushSDKName = @"ThinkingDataPush";
static NSString * const kTDPushEventTypeTrackToken = @"deviceToken";
static NSString * const kTDPushEventTypeClickNotification = @"clickNotification";

static NSString * const kTDAnalyticsSDKName = @"ThinkingDataAnalytics";
static NSString * const kTDAnalyticsEventInit = @"TDAnalyticsInit";

ThinkingMod(TDAnalyticsModule)
@interface TDAnalyticsModule ()<TAModuleProtocol>

@end

static NSDictionary *_cacheDeviceToken;

@implementation TDAnalyticsModule

- (void)modDidCustomEvent:(TAContext *)context {
    NSString *moduleName = context.customParam[@"module"];
    NSDictionary *pushSDKInfo = context.customParam[@"params"];
    
    if ([moduleName isEqualToString:kTDPushSDKName]) {
        NSString *eventType = pushSDKInfo[@"type"];
        if ([eventType isEqualToString:kTDPushEventTypeTrackToken]) {
            NSDictionary *deviceToken = pushSDKInfo[@"deviceToken"];
            [self trackDeviceToken:deviceToken];
        } else if ([eventType isEqualToString:kTDPushEventTypeClickNotification]) {
            NSDictionary *userInfo = pushSDKInfo[@"userInfo"];
            [self trackClickNotification:userInfo];
        }
    } else if ([moduleName isEqualToString:kTDAnalyticsSDKName]) {
        NSString *eventType = pushSDKInfo[@"type"];
        if ([eventType isEqualToString:kTDAnalyticsEventInit]) {
            [self trackCacheEvent];
        }
    }
}

- (void)trackCacheEvent {
    if (_cacheDeviceToken) {
        [self trackDeviceToken:_cacheDeviceToken];
    }
}

- (void)trackDeviceToken:(NSDictionary *)deviceToken {
    if (deviceToken == nil || ![deviceToken isKindOfClass:[NSDictionary class]]) return;
    
    NSMutableDictionary *dic = [ThinkingAnalyticsSDK _getAllInstances];
    if (dic.count > 0) {
        for (NSString *instanceToken in dic.allKeys) {
            ThinkingAnalyticsSDK *instance = dic[instanceToken];
            
            [instance innerUserSet:deviceToken];
            [instance innerFlush];
            
            _cacheDeviceToken = nil;
        }
    } else {
        _cacheDeviceToken = deviceToken;
    }
}

- (void)trackClickNotification:(NSDictionary *)userInfo {
#if TARGET_OS_IOS
    NSDictionary *opsReceiptProperties = [self extractOpsPropertiesFromNotificationUserInfo:userInfo];
    if (opsReceiptProperties) {
        NSMutableDictionary *dic = [ThinkingAnalyticsSDK _getAllInstances];
        for (NSString *instanceToken in dic.allKeys) {
            ThinkingAnalyticsSDK *instance = dic[instanceToken];
            TDPushClickEvent *pushEvent = [[TDPushClickEvent alloc] initWithName:@"te_ops_push_click"];
            pushEvent.ops = opsReceiptProperties;
            [instance autoTrackWithEvent:pushEvent properties:@{}];
            [instance innerFlush];
        }
    }
#endif
}

- (NSDictionary * _Nullable)extractOpsPropertiesFromNotificationUserInfo:(NSDictionary *)userInfo {
    id extras = userInfo[@"te_extras"];
    if (extras && [extras isKindOfClass:[NSString class]]) {
        NSString *tmpStr = (NSString *)extras;
        NSData *jsonData = [tmpStr dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSError *jsonError = nil;
            id jsonResult = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:&jsonError];
            if (jsonError) {
                NSLog(@"[ThinkingData] The json parsing of push notification content failed.");
            }
            if ([jsonResult isKindOfClass:[NSDictionary class]]) {
                NSDictionary *responseDic = (NSDictionary *)jsonResult;
                id opsProperties = responseDic[@"#ops_receipt_properties"];
                NSDictionary *opsReceiptProperties = nil;
                if ([opsProperties isKindOfClass:[NSString class]]) {
                    NSError *err = nil;
                    id opsJsonObj = [NSJSONSerialization JSONObjectWithData:[opsProperties dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                    if ([opsJsonObj isKindOfClass:NSDictionary.class]) {
                        opsReceiptProperties = opsJsonObj;
                    }
                } else if ([opsProperties isKindOfClass:[NSDictionary class]]) {
                    opsReceiptProperties = opsProperties;
                }
                return opsReceiptProperties;
            }
        }
    }
    return nil;
}

@end
