//
//  Target_Analytics.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2024/3/18.
//

#import "Target_Analytics.h"
#import "TDAnalytics+Public.h"
#import "TDAnalytics+Multiple.h"
#import "TDAnalytics+Private.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDAnalyticsPresetProperty.h"

#if __has_include(<ThinkingDataCore/ThinkingDataCore.h>)
#import <ThinkingDataCore/ThinkingDataCore.h>
#else
#import "ThinkingDataCore.h"
#endif

@implementation Target_Analytics

- (void)Action_nativeInitWithParams:(NSDictionary *)params {
    TDSettings *settings = params[@"settings"];
    if (![settings isKindOfClass:TDSettings.class]) {
        return;
    }
    [TDAnalytics enableLog:settings.enableLog];
    
    TDConfig *config = [[TDConfig alloc] init];
    config.appid = settings.appId;
    config.serverUrl = settings.serverUrl;
    
    TDMode mode = TDModeNormal;
    switch (settings.mode) {
        case TDSDKModeNomal:{
            mode = TDModeNormal;
        } break;
        case TDSDKModeDebug:{
            mode = TDModeDebug;
        } break;
        case TDSDKModeDebugOnly:{
            mode = TDModeDebugOnly;
        } break;
        default:
            break;
    }
    config.mode = mode;
    config.appid = settings.appId;
    config.defaultTimeZone = settings.defaultTimeZone;
    
    if (![NSString td_isEmpty:settings.encryptKey]) {
        [config enableEncryptWithVersion:settings.encryptVersion publicKey:settings.encryptKey];
    }
    
    config.enableAutoPush = settings.enableAutoPush;
    config.enableAutoCalibrated = settings.enableAutoCalibrated;
    [TDAnalytics startAnalyticsWithConfig:config];
}

- (nullable NSString *)Action_nativeGetAccountIdWithParams:(nullable NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSString *accountId = [[ThinkingAnalyticsSDK instanceWithAppid:appId] innerAccountId];
    return accountId;
}

- (nullable NSString *)Action_nativeGetDistinctIdWithParams:(nullable NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSString *distinctId = [TDAnalytics getDistinctIdWithAppId:appId];
    return distinctId;
}

- (void)Action_nativeTrackEventWithParams:(nullable NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSString *eventName = params[@"eventName"];
    NSDictionary *properties = params[@"properties"];
    if ([eventName isKindOfClass:NSString.class] && eventName.length > 0) {
        [TDAnalytics track:eventName properties:properties withAppId:appId];
        [TDAnalytics flushWithAppId:appId];
    }
}

- (void)Action_nativeUserSetWithParams:(nullable NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSDictionary *properties = params[@"properties"];
    if ([properties isKindOfClass:NSDictionary.class] && properties.count > 0) {
        [TDAnalytics userSet:properties withAppId:appId];
        [TDAnalytics flushWithAppId:appId];
    }
}

- (nullable NSDictionary *)Action_nativeGetPresetPropertiesWithParams:(nullable NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSDictionary *dict = [TDAnalyticsPresetProperty propertiesWithAppId:appId];
    return dict;
}

- (void)Action_nativeTrackDebugEventWithParams:(NSDictionary *)params {
    NSString *appId = params[@"appId"];
    NSString *eventName = params[@"eventName"];
    NSDictionary *properties = params[@"properties"];
    if ([eventName isKindOfClass:NSString.class] && eventName.length > 0) {
        [TDAnalytics trackDebug:eventName properties:properties appId:appId];
    }
}

- (BOOL)Action_nativeGetEnableAutoPushWithParams:(NSDictionary *)params {
    NSString *appId = params[@"appId"];
    return [[[ThinkingAnalyticsSDK instanceWithAppid:appId] config] enableAutoPush];
}

- (NSArray<NSString *> *)Action_nativeGetAllAppIdsWithParams:(NSDictionary *)params {
    NSDictionary *instances = [ThinkingAnalyticsSDK _getAllInstances];
    return instances.allKeys;
}

- (NSString *)Action_nativeGetSDKVersionWithParams:(NSDictionary *)params {
    return [TDAnalytics getSDKVersion];
}

@end
