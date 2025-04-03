//
//  TDMediator+Analytics.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/6.
//

#if __has_include(<ThinkingDataCore/TDMediator.h>)
#import <ThinkingDataCore/TDMediator.h>
#else
#import "TDMediator.h"
#endif

#if __has_include(<ThinkingDataCore/TDSettings.h>)
#import <ThinkingDataCore/TDSettings.h>
#else
#import "TDSettings.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kTDMediatorTargetAnalytics;

@interface TDMediator (Analytics)

- (void)tdAnalyticsInitWithSettings:(nullable TDSettings *)settings;

- (nullable NSString *)tdAnalyticsGetAccountIdWithAppId:(nullable NSString *)appId;

- (nullable NSString *)tdAnalyticsGetDistinctIdWithAppId:(nullable NSString *)appId;

- (void)tdAnalyticsTrackEvent:(nonnull NSString *)eventName properties:(nullable NSDictionary *)properties appId:(nullable NSString *)appId;

- (void)tdAnalyticsUserSetProperties:(nonnull NSDictionary *)properties appId:(nullable NSString *)appId;

- (nullable NSDictionary *)tdAnalyticsGetPresetPropertiesWithAppId:(nullable NSString *)appId;

- (void)tdAnalyticsTrackDebugEvent:(nonnull NSString *)eventName properties:(nullable NSDictionary *)properties appId:(nullable NSString *)appId;

- (BOOL)tdAnalyticsGetEnableAutoPushWithAppId:(nullable NSString *)appId;

- (NSArray<NSString *> *)tdAnalyticsGetAllAppIds;

- (nullable NSString *)tdAnalyticsGetSDKVersion;

@end

NS_ASSUME_NONNULL_END
