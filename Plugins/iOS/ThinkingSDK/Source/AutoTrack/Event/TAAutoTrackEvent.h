//
//  TAAutoTrackEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TATrackEvent.h"
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoTrackEvent : TATrackEvent

/// It is used to record the dynamic public properties of automatic collection events. The dynamic public properties need to be obtained in the current thread where the event occurs
@property (nonatomic, strong) NSDictionary *autoDynamicSuperProperties;

/// Static public property for logging autocollection events
@property (nonatomic, strong) NSDictionary *autoSuperProperties;

/// Returns the automatic collection type
- (ThinkingAnalyticsAutoTrackEventType)autoTrackEventType;

@end

NS_ASSUME_NONNULL_END
