//
//  TDNotificationManager+Analytics.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/12.
//

#import "TDNotificationManager+Analytics.h"

NSString * const kAnalyticsNotificationNameInit = @"kAnalyticsNotificationNameInit";
NSString * const kAnalyticsNotificationNameLogin = @"kAnalyticsNotificationNameLogin";
NSString * const kAnalyticsNotificationNameLogout = @"kAnalyticsNotificationNameLogout";
NSString * const kAnalyticsNotificationNameSetDistinctId = @"kAnalyticsNotificationNameSetDistinctId";
NSString * const kAnalyticsNotificationNameAppInstall = @"kAnalyticsNotificationNameAppInstall";
NSString * const kAnalyticsNotificationNameTrack = @"kAnalyticsNotificationNameTrack";

NSString * const kAnalyticsNotificationParamsAppId = @"appId";
NSString * const kAnalyticsNotificationParamsServerUrl = @"serverUrl";
NSString * const kAnalyticsNotificationParamsAccountId = @"accountId";
NSString * const kAnalyticsNotificationParamsDistinctId = @"distinctId";
NSString * const kAnalyticsNotificationParamsEvent = @"event";


@implementation TDNotificationManager (Analytics)

+ (void)postAnalyticsInitEventWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl {
    if (appId.length == 0 || serverUrl.length == 0) {
        return;
    }
    NSDictionary *userInfo = @{
        kAnalyticsNotificationParamsAppId: appId,
        kAnalyticsNotificationParamsServerUrl: serverUrl
    };
    [self postNotificationName:kAnalyticsNotificationNameInit object:nil userInfo:userInfo];
}

+ (void)postAnalyticsLoginEventWithAppId:(NSString *)appId accountId:(NSString *)accountId distinctId:(NSString *)distinctId {
    if (appId.length == 0 || accountId.length == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        kAnalyticsNotificationParamsAppId: appId,
        kAnalyticsNotificationParamsAccountId: accountId,
    }];
    if (distinctId.length) {
        userInfo[kAnalyticsNotificationParamsDistinctId] = distinctId;
    }
    [self postNotificationName:kAnalyticsNotificationNameLogin object:nil userInfo:userInfo];
}

+ (void)postAnalyticsLogoutEventWithAppId:(NSString *)appId distinctId:(NSString *)distinctId {
    if (appId.length == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        kAnalyticsNotificationParamsAppId: appId,
    }];
    if (distinctId.length) {
        userInfo[kAnalyticsNotificationParamsDistinctId] = distinctId;
    }
    
    [self postNotificationName:kAnalyticsNotificationNameLogout object:nil userInfo:userInfo];
}

+ (void)postAnalyticsSetDistinctIdEventWithAppId:(NSString *)appId accountId:(NSString *)accountId distinctId:(NSString *)distinctId {
    if (appId.length == 0 || distinctId.length == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        kAnalyticsNotificationParamsAppId: appId,
        kAnalyticsNotificationParamsDistinctId: distinctId,
    }];
    if (accountId.length) {
        userInfo[kAnalyticsNotificationParamsAccountId] = accountId;
    }
    
    [self postNotificationName:kAnalyticsNotificationNameSetDistinctId object:nil userInfo:userInfo];
}

+ (void)postAnalyticsAppInstallEventWithAppId:(NSString *)appId {
    if (appId.length == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        kAnalyticsNotificationParamsAppId: appId,
    }];
    [self postNotificationName:kAnalyticsNotificationNameAppInstall object:nil userInfo:userInfo];
}

+ (void)postAnalyticsTrackWithAppId:(NSString *)appId event:(NSDictionary *)event {
    if (appId.length == 0 || event.count == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        kAnalyticsNotificationParamsAppId: appId,
        kAnalyticsNotificationParamsEvent: event,
    }];
    [self postNotificationName:kAnalyticsNotificationNameTrack object:nil userInfo:userInfo];
}

@end
