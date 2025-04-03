//
//  TDAnalytics+Public.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#import "TDAnalytics+Public.h"
#import "TDAnalytics+Multiple.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDLogging.h"
#import "TDPublicConfig.h"
#import "TDConfigPrivate.h"

#if __has_include(<ThinkingDataCore/TDCalibratedTime.h>)
#import <ThinkingDataCore/TDCalibratedTime.h>
#else
#import "TDCalibratedTime.h"
#endif

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif

#if __has_include(<ThinkingDataCore/NSString+TDCore.h>)
#import <ThinkingDataCore/NSString+TDCore.h>
#else
#import "NSString+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/NSURL+TDCore.h>)
#import <ThinkingDataCore/NSURL+TDCore.h>
#else
#import "NSURL+TDCore.h"
#endif

@implementation TDAnalytics (Public)

#pragma mark - Logging

+ (void)enableLog:(BOOL)enable {
    [TDLogging sharedInstance].loggingLevel = enable ? TDLoggingLevelDebug : TDLoggingLevelNone;
}

#pragma mark - Calibrate time

+ (void)calibrateTime:(NSTimeInterval)timestamp {
    [[TDCalibratedTime sharedInstance] recalibrationWithTimeInterval:timestamp/1000.0];
}

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer {
    if ([ntpServer isKindOfClass:[NSString class]] && ntpServer.length > 0) {
        [[TDCalibratedTime sharedInstance] recalibrationWithNtps:@[ntpServer]];
    }
}

// MARK: info

+ (nullable NSString *)getLocalRegion {
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    return countryCode;
}

+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion {
    if (libName.length > 0) {
        [TDDeviceInfo sharedManager].libName = libName;
    }
    if (libVersion.length > 0) {
        [TDDeviceInfo sharedManager].libVersion = libVersion;
    }
}

+ (NSString *)getSDKVersion {
    return TDPublicConfig.version;
}

+ (NSString *)getDeviceId {
    return [TDCoreDeviceInfo deviceId];
}

+ (NSString *)timeStringWithDate:(NSDate *)date {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [TDAnalytics timeStringWithDate:date withAppId:appId];
}

//MARK: - init

+ (void)startAnalyticsWithAppId:(NSString *)appId serverUrl:(NSString *)url {
    TDConfig *config = [[TDConfig alloc] init];
    config.appid = appId;
    config.serverUrl = url;
    [self startAnalyticsWithConfig:config];
}

+ (void)startAnalyticsWithConfig:(TDConfig *)config {
    if (!config) {
        return;
    }
    config.appid = [config.appid td_trim];
    
    NSString *appId = config.appid;
    if (appId.length == 0) {
        return;
    }
    
    NSMutableDictionary *instances = [ThinkingAnalyticsSDK _getAllInstances];
    if ([instances objectForKey:[config innerGetMapInstanceToken]]) {
        return;
    }
    
    config.serverUrl = [NSURL td_baseUrlStringWithString:config.serverUrl];
    NSString *url = config.serverUrl;
    if (url.length == 0) {
        return;
    }
    
    ThinkingAnalyticsSDK *sdk = [[ThinkingAnalyticsSDK alloc] initWithConfig:config];
    TDLogInfo(@"instance token: %@", [sdk.config innerGetMapInstanceToken]);
}

+ (NSString *)lightInstanceIdWithAppId:(NSString *)appId {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    if (instance) {
        ThinkingAnalyticsSDK *lightInstance = [instance innerCreateLightInstance];
        return [lightInstance.config innerGetMapInstanceToken];
    }
    return nil;
}

//MARK: track

+ (void)flush {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics flushWithAppId:appId];
}

+ (void)setTrackStatus:(TDTrackStatus)status {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setTrackStatus:status withAppId:appId];
}

+ (void)track:(NSString *)eventName {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics track:eventName withAppId:appId];
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics track:eventName properties:properties withAppId:appId];
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics track:eventName properties:properties time:time timeZone:timeZone withAppId:appId];
}

+ (void)trackWithEventModel:(TDEventModel *)eventModel {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics trackWithEventModel:eventModel withAppId:appId];
}

+ (void)timeEvent:(NSString *)eventName {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics timeEvent:eventName withAppId:appId];
}

//MARK: user property

+ (void)userSet:(NSDictionary<NSString *, id> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userSet:properties withAppId:appId];
}

+ (void)userSetOnce:(NSDictionary<NSString *, id> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userSetOnce:properties withAppId:appId];
}

+ (void)userUnset:(NSString *)propertyName {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userUnset:propertyName withAppId:appId];
}

+ (void)userUnsets:(NSArray<NSString *> *)propertyNames {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userUnsets:propertyNames withAppId:appId];
}

+ (void)userAdd:(NSDictionary<NSString *, id> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userAdd:properties withAppId:appId];
}

+ (void)userAddWithName:(NSString *)propertyName andValue:(NSNumber *)propertyValue {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userAddWithName:propertyName andValue:propertyValue withAppId:appId];
}

+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userAppend:properties withAppId:appId];
}

+ (void)userUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userUniqAppend:properties withAppId:appId];
}

+ (void)userDelete {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics userDeleteWithAppId:appId];
}

//MARK: super property & preset property

+ (void)setSuperProperties:(NSDictionary<NSString *, id> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setSuperProperties:properties withAppId:appId];
}

+ (void)unsetSuperProperty:(NSString *)property {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics unsetSuperProperty:property withAppId:appId];
}

+ (void)clearSuperProperties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics clearSuperPropertiesWithAppId:appId];
}

+ (NSDictionary *)getSuperProperties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [TDAnalytics getSuperPropertiesWithAppId:appId];
}

+ (void)setDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))propertiesHandler {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setDynamicSuperProperties:propertiesHandler withAppId:appId];
}

+ (TDPresetProperties *)getPresetProperties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [TDAnalytics getPresetPropertiesWithAppId:appId];
}

//MARK: error callback

+ (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics registerErrorCallback:errorCallback withAppId:appId];
}

//MARK: custom property

+ (void)setDistinctId:(NSString *)distinctId {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setDistinctId:distinctId withAppId:appId];
}

+ (NSString *)getDistinctId {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [TDAnalytics getDistinctIdWithAppId:appId];
}

+ (void)login:(NSString *)accountId {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics login:accountId withAppId:appId];
}

+ (NSString *)getAccountId {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [TDAnalytics getAccountIdWithAppId:appId];
}

+ (void)logout {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics logoutWithAppId:appId];
}

+ (void)setUploadingNetworkType:(TDReportingNetworkType)type {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setUploadingNetworkType:type withAppId:appId];
}

// MARK: auto track

#if TARGET_OS_IOS

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics enableAutoTrack:eventType withAppId:appId];
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics enableAutoTrack:eventType properties:properties withAppId:appId];
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType callback:(NSDictionary *(^ _Nullable)(TDAutoTrackEventType, NSDictionary *))callback API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics enableAutoTrack:eventType callback:callback withAppId:appId];
}

+ (void)ignoreAutoTrackViewControllers:(nonnull NSArray<NSString *> *)controllers API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics ignoreAutoTrackViewControllers:controllers withAppId:appId];
}

+ (void)ignoreViewType:(nonnull Class)aClass API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics ignoreViewType:aClass withAppId:appId];
}

+ (void)setAutoTrackProperties:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setAutoTrackProperties:eventType properties:properties withAppId:appId];
}

+ (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *,id> * _Nonnull (^)(void))dynamicSuperProperties API_UNAVAILABLE(macos){
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [TDAnalytics setAutoTrackDynamicProperties:dynamicSuperProperties withAppId:appId];
}

#endif

@end
