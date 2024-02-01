//
//  TAAutoTrackSuperProperty.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoTrackSuperProperty : NSObject

- (void)registerSuperProperties:(NSDictionary *)properties withType:(ThinkingAnalyticsAutoTrackEventType)type;

- (NSDictionary *)currentSuperPropertiesWithEventName:(NSString *)eventName;

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(ThinkingAnalyticsAutoTrackEventType, NSDictionary *))dynamicSuperProperties;

- (NSDictionary *)obtainDynamicSuperPropertiesWithType:(ThinkingAnalyticsAutoTrackEventType)type currentProperties:(NSDictionary *)properties;

/// Only used for auto track in Unity3D environment
/// - Parameter dynamicSuperProperties: dynamic properties
- (void)registerAutoTrackDynamicProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties;

/// Only used for auto track in Unity3D environment
- (NSDictionary *)obtainAutoTrackDynamicSuperProperties;

- (void)clearSuperProperties;

@end

NS_ASSUME_NONNULL_END
