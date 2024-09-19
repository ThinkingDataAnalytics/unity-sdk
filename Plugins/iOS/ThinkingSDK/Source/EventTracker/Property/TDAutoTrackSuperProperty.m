//
//  TDAutoTrackSuperProperty.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TDAutoTrackSuperProperty.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDAutoTrackSuperProperty ()
@property (atomic, strong) NSMutableDictionary<NSString *, NSDictionary *> *eventProperties;
@property (nonatomic, copy) NSDictionary *(^dynamicSuperProperties)(TDAutoTrackEventType type, NSDictionary *properties);
/// Only used for auto track in Unity3D environment
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^autoTrackDynamicSuperProperties)(void);

@end

@implementation TDAutoTrackSuperProperty

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventProperties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerSuperProperties:(NSDictionary *)properties withType:(TDAutoTrackEventType)type {
    NSDictionary<NSNumber *, NSString *> *autoTypes = @{
        @(ThinkingAnalyticsEventTypeAppStart) : TD_APP_START_EVENT,
        @(ThinkingAnalyticsEventTypeAppEnd) : TD_APP_END_EVENT,
        @(ThinkingAnalyticsEventTypeAppClick) : TD_APP_CLICK_EVENT,
        @(ThinkingAnalyticsEventTypeAppInstall) : TD_APP_INSTALL_EVENT,
        @(ThinkingAnalyticsEventTypeAppViewCrash) : TD_APP_CRASH_EVENT,
        @(ThinkingAnalyticsEventTypeAppViewScreen) : TD_APP_VIEW_EVENT
    };
    
    NSArray<NSNumber *> *typeKeys = autoTypes.allKeys;
    for (NSInteger i = 0; i < typeKeys.count; i++) {
        NSNumber *key = typeKeys[i];
        TDAutoTrackEventType eventType = key.integerValue;
        if ((type & eventType) == eventType) {
            NSString *eventName = autoTypes[key];
            if (properties) {
                
                NSDictionary *oldProperties = self.eventProperties[eventName];
                if (oldProperties && [oldProperties isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutiOldProperties = [oldProperties mutableCopy];
                    [mutiOldProperties addEntriesFromDictionary:properties];
                    self.eventProperties[eventName] = mutiOldProperties;
                } else {
                    self.eventProperties[eventName] = properties;
                }
                
                
                if (eventType == ThinkingAnalyticsEventTypeAppStart) {
                    NSDictionary *startParam = self.eventProperties[TD_APP_START_EVENT];
                    if (startParam && [startParam isKindOfClass:[NSDictionary class]]) {
                        self.eventProperties[TD_APP_START_BACKGROUND_EVENT] = startParam;
                    }
                }
            }
        }
    }
}


- (NSDictionary *)currentSuperPropertiesWithEventName:(NSString *)eventName {
    NSDictionary *autoEventProperty = [self.eventProperties objectForKey:eventName];
    
    NSDictionary *validProperties = [TDPropertyValidator validateProperties:[autoEventProperty copy]];
    return validProperties;
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(TDAutoTrackEventType, NSDictionary *))dynamicSuperProperties {
    @synchronized (self) {
        self.dynamicSuperProperties = dynamicSuperProperties;
    }
}

- (NSDictionary *)obtainDynamicSuperPropertiesWithType:(TDAutoTrackEventType)type currentProperties:(NSDictionary *)properties {
    @synchronized (self) {
        if (self.dynamicSuperProperties) {
            NSDictionary *result = self.dynamicSuperProperties(type, properties);
            
            NSDictionary *validProperties = [TDPropertyValidator validateProperties:[result copy]];
            return validProperties;
        }
        return nil;
    }
}

- (void)registerAutoTrackDynamicProperties:(NSDictionary<NSString *,id> * _Nonnull (^)(void))dynamicSuperProperties {
    @synchronized (self) {
        self.autoTrackDynamicSuperProperties = dynamicSuperProperties;
    }
}

- (NSDictionary *)obtainAutoTrackDynamicSuperProperties {
    @synchronized (self) {
        if (self.autoTrackDynamicSuperProperties) {
            NSDictionary *properties = self.autoTrackDynamicSuperProperties();
            
            NSDictionary *validProperties = [TDPropertyValidator validateProperties:[properties copy]];
            return validProperties;
        }
        return nil;
    }
}

- (void)clearSuperProperties {
    self.eventProperties = [@{} mutableCopy];
}

//MARK: - Private Methods



@end
