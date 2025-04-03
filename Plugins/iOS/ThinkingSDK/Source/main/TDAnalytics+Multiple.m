//
//  TDAnalytics+Multiple.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#import "TDAnalytics+Multiple.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDConfigPrivate.h"
#if TARGET_OS_IOS
#import "TDAutoTrackManager.h"
#endif

@implementation TDAnalytics (Multiple)

+ (void)flushWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerFlush];
}

+ (void)setTrackStatus:(TDTrackStatus)status withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerSetTrackStatus:status];
}

+ (void)track:(NSString *)eventName withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTrack:eventName];
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTrack:eventName properties:properties];
}

+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTrack:eventName properties:properties time:time timeZone:timeZone];
}

+ (void)trackWithEventModel:(TDEventModel *)eventModel withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTrackWithEventModel:eventModel];
}

+ (void)timeEvent:(NSString *)eventName withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTimeEvent:eventName];
}

//MARK: user property

+ (void)userSet:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserSet:properties];
}

+ (void)userSetOnce:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserSetOnce:properties];
}

+ (void)userUnset:(NSString *)propertyName withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserUnset:propertyName];
}

+ (void)userUnsets:(NSArray<NSString *> *)propertyNames withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserUnsets:propertyNames];
}

+ (void)userAdd:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserAdd:properties];
}

+ (void)userAddWithName:(NSString *)propertyName andValue:(NSNumber *)propertyValue withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserAdd:propertyName andPropertyValue:propertyValue];
}

+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserAppend:properties];
}

+ (void)userUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserUniqAppend:properties];
}

+ (void)userDeleteWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUserDelete];
}

//MARK: super property & preset property

+ (void)setSuperProperties:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerSetSuperProperties:properties];
}

+ (void)unsetSuperProperty:(NSString *)property withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerUnsetSuperProperty:property];
}

+ (void)clearSuperPropertiesWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerClearSuperProperties];
}

+ (NSDictionary *)getSuperPropertiesWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    return [teSDK innerCurrentSuperProperties];
}

+ (void)setDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))propertiesHandler withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerRegisterDynamicSuperProperties:propertiesHandler];
}

+ (TDPresetProperties *)getPresetPropertiesWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    return [teSDK innerGetPresetProperties];
}

//MARK: error callback

+ (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerRegisterErrorCallback:errorCallback];
}

//MARK: custom property

+ (void)setDistinctId:(NSString *)distinctId withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerSetIdentify:distinctId];
}

+ (NSString *)getDistinctIdWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    return [teSDK innerDistinctId];
}

+ (void)login:(NSString *)accountId withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerLogin:accountId];
}

+ (void)logoutWithAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerLogout];
}

+ (NSString *)getAccountIdWithAppId:(NSString *)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    return [teSDK innerAccountId];
}

+ (void)setUploadingNetworkType:(TDReportingNetworkType)type withAppId:(NSString * _Nullable)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerSetNetworkType:type];
}

+ (NSString *)timeStringWithDate:(NSDate *)date withAppId:(NSString *)appId {
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    return [teSDK innetGetTimeString:date];
}

//MARK: - auto track

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType callback:(NSDictionary *(^ _Nullable)(TDAutoTrackEventType, NSDictionary *))callback withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
    [self innerEnableAutoTrack:eventType properties:nil callback:callback withAppId:appId];
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
    [self innerEnableAutoTrack:eventType properties:properties callback:nil withAppId:appId];
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
    [self innerEnableAutoTrack:eventType properties:nil callback:nil withAppId:appId];
}

+ (void)ignoreAutoTrackViewControllers:(nonnull NSArray<NSString *> *)controllers withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    if ([teSDK hasDisabled]) {
        return;
    }
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    @synchronized (teSDK.ignoredViewControllers) {
        [teSDK.ignoredViewControllers addObjectsFromArray:controllers];
    }
}

+ (void)ignoreViewType:(nonnull Class)aClass withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    if ([teSDK hasDisabled]) {
        return;
    }
    @synchronized (teSDK.ignoredViewTypeList) {
        [teSDK.ignoredViewTypeList addObject:aClass];
    }
}

+ (void)setAutoTrackProperties:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
#if TARGET_OS_IOS
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    if ([teSDK hasDisabled]) {
        return;
    }
    if (properties == nil) {
        return;
    }
    @synchronized (teSDK.autoTrackSuperProperty) {
        [teSDK.autoTrackSuperProperty registerSuperProperties:[properties copy] withType:eventType];
    }
#endif
}

+ (void)innerEnableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties callback:(NSDictionary *(^ _Nullable)(TDAutoTrackEventType eventType, NSDictionary *properties))callback withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos){
#if TARGET_OS_IOS
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    
    if (teSDK.autoTrackSuperProperty == nil) {
        teSDK.autoTrackSuperProperty = [[TDAutoTrackSuperProperty alloc] init];
    }
    [teSDK.autoTrackSuperProperty registerSuperProperties:properties withType:eventType];
    [teSDK.autoTrackSuperProperty registerDynamicSuperProperties:callback];
    
    NSString *instanceToken = [teSDK.config innerGetMapInstanceToken];
    [[TDAutoTrackManager sharedManager] trackWithAppid:instanceToken withOption:eventType];
#endif
}

+ (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *,id> * _Nonnull (^)(void))dynamicSuperProperties withAppId:(NSString *)appId {
#if TARGET_OS_IOS
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    if ([teSDK hasDisabled]) {
        return;
    }
    @synchronized (teSDK.autoTrackSuperProperty) {
        [teSDK.autoTrackSuperProperty registerAutoTrackDynamicProperties:dynamicSuperProperties];
    }
#endif
}

//MARK: -

@end
