//
//  TDMediator+Analytics.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/6.
//

#import "TDMediator+Analytics.h"

NSString * const kTDMediatorTargetAnalytics = @"Analytics";

NSString * const kTDMediatorTargetAnalyticsActionNativeInit = @"nativeInitWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetAccountId = @"nativeGetAccountIdWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetDistinctId = @"nativeGetDistinctIdWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetPresetProperties = @"nativeGetPresetPropertiesWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeTrackEvent = @"nativeTrackEventWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeUserSet = @"nativeUserSetWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeTrackDebugEvent = @"nativeTrackDebugEventWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetEnableAutoPush = @"nativeGetEnableAutoPushWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetAllAppIds = @"nativeGetAllAppIdsWithParams";
NSString * const kTDMediatorTargetAnalyticsActionNativeGetSDKVersion = @"nativeGetSDKVersionWithParams";

@implementation TDMediator (Analytics)

- (void)tdAnalyticsInitWithSettings:(TDSettings *)settings {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (settings) {
        params[@"settings"] = settings;
    }
    [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeInit params:params shouldCacheTarget:NO];
}

- (nullable NSString *)tdAnalyticsGetAccountIdWithAppId:(nullable NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    NSString *accountId = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetAccountId params:params shouldCacheTarget:NO];
    return accountId;
}

- (nullable NSString *)tdAnalyticsGetDistinctIdWithAppId:(nullable NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    NSString *distinctId = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetDistinctId params:params shouldCacheTarget:NO];
    return distinctId;
}

- (void)tdAnalyticsTrackEvent:(nonnull NSString *)eventName properties:(nullable NSDictionary *)properties appId:(nullable NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    if (eventName) {
        params[@"eventName"] = eventName;
    }
    if (properties) {
        params[@"properties"] = properties;
    }
    [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeTrackEvent params:params shouldCacheTarget:NO needModuleReady:YES];
}

- (void)tdAnalyticsUserSetProperties:(nonnull NSDictionary *)properties appId:(nullable NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    if (properties) {
        params[@"properties"] = properties;
    }
    [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeUserSet params:params shouldCacheTarget:NO needModuleReady:YES];
}

- (nullable NSDictionary *)tdAnalyticsGetPresetPropertiesWithAppId:(NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    NSDictionary *dict = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetPresetProperties params:params shouldCacheTarget:NO];
    return dict;
}

- (void)tdAnalyticsTrackDebugEvent:(NSString *)eventName properties:(NSDictionary *)properties appId:(NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    if (eventName) {
        params[@"eventName"] = eventName;
    }
    if (properties) {
        params[@"properties"] = properties;
    }
    [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeTrackDebugEvent params:params shouldCacheTarget:NO needModuleReady:YES];
}

- (BOOL)tdAnalyticsGetEnableAutoPushWithAppId:(NSString *)appId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (appId) {
        params[@"appId"] = appId;
    }
    BOOL enableAutoPush = [[[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetEnableAutoPush params:params shouldCacheTarget:NO] boolValue];
    return enableAutoPush;
}

- (NSArray<NSString *> *)tdAnalyticsGetAllAppIds {
    NSArray *appIds = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetAllAppIds params:nil shouldCacheTarget:NO];
    return appIds;
}

- (nullable NSString *)tdAnalyticsGetSDKVersion {
    NSString *version = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetAnalytics action:kTDMediatorTargetAnalyticsActionNativeGetSDKVersion params:nil shouldCacheTarget:NO];
    return version;
}

@end
