//
//  TDNotificationManager+Analytics.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/12.
//

#if __has_include(<ThinkingDataCore/TDNotificationManager.h>)
#import <ThinkingDataCore/TDNotificationManager.h>
#else
#import "TDNotificationManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// init
extern NSString * const kAnalyticsNotificationNameInit;
// login
extern NSString * const kAnalyticsNotificationNameLogin;
// logout
extern NSString * const kAnalyticsNotificationNameLogout;
// set distinct id
extern NSString * const kAnalyticsNotificationNameSetDistinctId;
// app install event
extern NSString * const kAnalyticsNotificationNameAppInstall;
// track event
extern NSString * const kAnalyticsNotificationNameTrack;

// params
extern NSString * const kAnalyticsNotificationParamsAppId;
extern NSString * const kAnalyticsNotificationParamsServerUrl;
extern NSString * const kAnalyticsNotificationParamsAccountId;
extern NSString * const kAnalyticsNotificationParamsDistinctId;
extern NSString * const kAnalyticsNotificationParamsEvent;

@interface TDNotificationManager (Analytics)

/// analytics init event
/// Observer will receive data:  e.g. {"appId": "", "serverUrl": ""}
+ (void)postAnalyticsInitEventWithAppId:(nonnull NSString *)appId serverUrl:(nonnull NSString *)serverUrl;

/// analytics login event
/// Observer will receive data:  e.g. {"appId": "", "accountId": "", "distinctId": ""}
+ (void)postAnalyticsLoginEventWithAppId:(nonnull NSString *)appId accountId:(nonnull NSString *)accountId distinctId:(nonnull NSString *)distinctId;

/// analytics logout event
/// Observer will receive data: e.g. {"appId": "", "distinctId": ""}
+ (void)postAnalyticsLogoutEventWithAppId:(nonnull NSString *)appId distinctId:(nonnull NSString *)distinctId;

/// analytics set distinct id event
/// Observer will receive data: e.g. {"appId": "", "accountId": "", "distinctId": ""}
+ (void)postAnalyticsSetDistinctIdEventWithAppId:(nonnull NSString *)appId accountId:(nullable NSString *)accountId distinctId:(nonnull NSString *)distinctId;

/// analytics app install event
+ (void)postAnalyticsAppInstallEventWithAppId:(NSString *)appId;

/// analytics track event
/// Observer will receive data: e.g. {"appId": "", "event": ""}
+ (void)postAnalyticsTrackWithAppId:(nonnull NSString *)appId event:(nonnull NSDictionary *)event;

@end

NS_ASSUME_NONNULL_END
