//
//  ThinkingAnalyticsSDK+OldPublic.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/10.
//

#import "ThinkingAnalyticsSDK+OldPublic.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDAnalytics+Public.h"
#import "TDAnalytics+Multiple.h"
#import "TDConfigPrivate.h"
#import "TDAnalytics+ThirdParty.h"
#import "TDAnalytics+WebView.h"

@implementation ThinkingAnalyticsSDK (OldPublic)

#pragma mark - Logging

+ (void)setLogLevel:(TDLoggingLevel)level {
    [TDLogging sharedInstance].loggingLevel = level;
}

#pragma mark - Calibrate time

+ (void)calibrateTime:(NSTimeInterval)timestamp {
    [TDAnalytics calibrateTime:timestamp];
}

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer {
    [TDAnalytics calibrateTimeWithNtp:ntpServer];
}

// MARK: info

+ (nullable NSString *)getLocalRegion {
    return [TDAnalytics getLocalRegion];
}

+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion {
    [TDAnalytics setCustomerLibInfoWithLibName:libName libVersion:libVersion];
}

+ (NSString *)getSDKVersion {
    return [TDAnalytics getSDKVersion];
}

+ (NSString *)getDeviceId {
    return [TDAnalytics getDeviceId];
}

+ (NSString *)timeStringWithDate:(NSDate *)date {
    return [TDAnalytics timeStringWithDate:date];
}

// MARK: init

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url {
    return [self startWithAppId:appId withUrl:url withConfig:nil];
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(nullable TDConfig *)config {
    if (!config) {
        config = [[TDConfig alloc] init];
    }
    config.appid = appId;
    config.serverUrl = url;
    return [ThinkingAnalyticsSDK startWithConfig:config];
}

+ (ThinkingAnalyticsSDK *)startWithConfig:(TDConfig *)config {
    [TDAnalytics startAnalyticsWithConfig:config];
    return [ThinkingAnalyticsSDK instanceWithAppid:[config innerGetMapInstanceToken]];
}

+ (nullable ThinkingAnalyticsSDK *)sharedInstance {
    return [ThinkingAnalyticsSDK defaultInstance];
}
+ (nullable ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid {
    return [ThinkingAnalyticsSDK instanceWithAppid:appid];
}
- (ThinkingAnalyticsSDK *)createLightInstance {
    return [self innerCreateLightInstance];
}
- (void)track:(NSString *)event {
    [TDAnalytics track:event withAppId:[self instanceAliasNameOrAppId]];
}
// TAThirdParty model used.
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict {
    [TDAnalytics track:event properties:propertieDict withAppId:[self instanceAliasNameOrAppId]];
}
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self track:event properties:propertieDict time:time timeZone:nil];
#pragma clang diagnostic pop
}
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    [TDAnalytics track:event properties:propertieDict time:time timeZone:timeZone withAppId:[self instanceAliasNameOrAppId]];
}
- (void)trackWithEventModel:(TDEventModel *)eventModel {
    [TDAnalytics trackWithEventModel:eventModel withAppId:[self instanceAliasNameOrAppId]];
}
- (void)trackFromAppExtensionWithAppGroupId:(NSString *)appGroupId {
    // deprecated
}
- (void)timeEvent:(NSString *)event {
    [TDAnalytics timeEvent:event withAppId:[self instanceAliasNameOrAppId]];
}
- (void)identify:(NSString *)distinctId {
    [TDAnalytics setDistinctId:distinctId withAppId:[self instanceAliasNameOrAppId]];
}

// TAThirdParty model used.
- (NSString *)getDistinctId {
    return [TDAnalytics getDistinctIdWithAppId:[self instanceAliasNameOrAppId]];
}

- (void)login:(NSString *)accountId {
    [TDAnalytics login:accountId withAppId:[self instanceAliasNameOrAppId]];
}
- (void)logout {
    [TDAnalytics logoutWithAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_set:(NSDictionary *)properties {
    [TDAnalytics userSet:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_set:(NSDictionary *)properties withTime:(NSDate * _Nullable)time {
    TDUserEventSet *event = [[TDUserEventSet alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)user_unset:(NSString *)propertyName {
    [TDAnalytics userUnset:propertyName withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_unset:(NSString *)propertyName withTime:(NSDate * _Nullable)time {
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary *properties = @{propertyName: @0};
        TDUserEventUnset *event = [[TDUserEventUnset alloc] init];
        if (time) {
            event.time = time;
            event.timeValueType = TDEventTimeValueTypeTimeOnly;
        }
        [self asyncUserEventObject:event properties:properties isH5:NO];
    }
}
- (void)user_setOnce:(NSDictionary *)properties {
    [TDAnalytics userSetOnce:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate * _Nullable)time {
    TDUserEventSetOnce *event = [[TDUserEventSetOnce alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)user_add:(NSDictionary *)properties {
    [TDAnalytics userAdd:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_add:(NSDictionary *)properties withTime:(NSDate * _Nullable)time {
    TDUserEventAdd *event = [[TDUserEventAdd alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    [TDAnalytics userAddWithName:propertyName andValue:propertyValue withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate * _Nullable)time {
    if (propertyName && propertyValue) {
        [self user_add:@{propertyName: propertyValue} withTime:time];
    }
}
- (void)user_delete {
    [TDAnalytics userDeleteWithAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_delete:(NSDate * _Nullable)time {
    TDUserEventDelete *event = [[TDUserEventDelete alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:nil isH5:NO];
}
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties {
    [TDAnalytics userAppend:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time {
    TDUserEventAppend *event = [[TDUserEventAppend alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    [TDAnalytics userUniqAppend:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time {
    TDUserEventUniqueAppend *event = [[TDUserEventUniqueAppend alloc] init];
    if (time) {
        event.time = time;
        event.timeValueType = TDEventTimeValueTypeTimeOnly;
    }
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)setSuperProperties:(NSDictionary *)properties {
    [TDAnalytics setSuperProperties:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)unsetSuperProperty:(NSString *)property {
    [TDAnalytics unsetSuperProperty:property withAppId:[self instanceAliasNameOrAppId]];
}
- (void)clearSuperProperties {
    [TDAnalytics clearSuperPropertiesWithAppId:[self instanceAliasNameOrAppId]];
}
- (NSDictionary *)currentSuperProperties {
    return [TDAnalytics getSuperPropertiesWithAppId:[self instanceAliasNameOrAppId]];
}
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties {
    [TDAnalytics setDynamicSuperProperties:dynamicSuperProperties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback {
    [TDAnalytics registerErrorCallback:errorCallback withAppId:[self instanceAliasNameOrAppId]];
}
- (TDPresetProperties *)getPresetProperties {
    return [TDAnalytics getPresetPropertiesWithAppId:[self instanceAliasNameOrAppId]];
}
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    [TDAnalytics setUploadingNetworkType:(TDReportingNetworkType)type withAppId:[self instanceAliasNameOrAppId]];
}
#if TARGET_OS_IOS
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    [TDAnalytics enableAutoTrack:(TDAutoTrackEventType)eventType withAppId:[self instanceAliasNameOrAppId]];
}
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    [TDAnalytics enableAutoTrack:(TDAutoTrackEventType)eventType properties:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback {
    [TDAnalytics enableAutoTrack:(TDAutoTrackEventType)eventType callback:^NSDictionary *(TDAutoTrackEventType type, NSDictionary *dict){
        return callback((ThinkingAnalyticsAutoTrackEventType)type, dict);
    } withAppId:[self instanceAliasNameOrAppId]];
}
- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    [TDAnalytics setAutoTrackProperties:(TDAutoTrackEventType)eventType properties:properties withAppId:[self instanceAliasNameOrAppId]];
}
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    [TDAnalytics ignoreAutoTrackViewControllers:controllers withAppId:[self instanceAliasNameOrAppId]];
}
- (void)ignoreViewType:(Class)aClass {
    [TDAnalytics ignoreViewType:aClass withAppId:[self instanceAliasNameOrAppId]];
}
- (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *,id> * _Nonnull (^)(void))dynamicSuperProperties {
    [TDAnalytics setAutoTrackDynamicProperties:dynamicSuperProperties withAppId:[self instanceAliasNameOrAppId]];
}
#endif

- (NSString *)getDeviceId {
    return [TDAnalytics getDeviceId];
}
- (void)flush {
    [TDAnalytics flushWithAppId:[self instanceAliasNameOrAppId]];
}
- (void)setTrackStatus: (TATrackStatus)status {
    [TDAnalytics setTrackStatus:(TDTrackStatus)status withAppId:[self instanceAliasNameOrAppId]];
}
- (void)enableTracking:(BOOL)enabled {
    [TDAnalytics setTrackStatus:enabled ? TDTrackStatusNormal : TDTrackStatusPause withAppId:[self instanceAliasNameOrAppId]];
}
- (void)optOutTracking {
    [TDAnalytics setTrackStatus:TDTrackStatusStop withAppId:[self instanceAliasNameOrAppId]];
}
- (void)optOutTrackingAndDeleteUser {
    TDUserEventDelete *deleteEvent = [[TDUserEventDelete alloc] init];
    deleteEvent.immediately = YES;
    [self asyncUserEventObject:deleteEvent properties:nil isH5:NO];
    
    [TDAnalytics setTrackStatus:TDTrackStatusStop withAppId:[self instanceAliasNameOrAppId]];
}
- (void)optInTracking {
    [TDAnalytics setTrackStatus:TDTrackStatusNormal withAppId:[self instanceAliasNameOrAppId]];
}
- (NSString *)getTimeString:(NSDate *)date {
    return [TDAnalytics timeStringWithDate:date withAppId:[self instanceAliasNameOrAppId]];
}

//MARK: - ThirdParty

#if TARGET_OS_IOS
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type {
    [TDAnalytics enableThirdPartySharing:(TDThirdPartyType)type properties:@{} withAppId:[self instanceAliasNameOrAppId]];
}

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap {
    [TDAnalytics enableThirdPartySharing:(TDThirdPartyType)type properties:customMap withAppId:[self instanceAliasNameOrAppId]];
}
#endif

//MARK: - WebView

- (void)addWebViewUserAgent {
    [TDAnalytics addWebViewUserAgent];
}

- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request {
    return [TDAnalytics showUpWebView:webView withRequest:request withAppId:[self instanceAliasNameOrAppId]];
}


@end
