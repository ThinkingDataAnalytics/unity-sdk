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

- (void)clearSuperProperties;

@end

NS_ASSUME_NONNULL_END
