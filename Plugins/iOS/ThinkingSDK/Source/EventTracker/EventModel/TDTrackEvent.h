//
//  TATrackEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN


@interface TDTrackEvent : TDBaseEvent
/// eventName
@property (nonatomic, copy) NSString *eventName;
/// Cumulative front activity time
@property (nonatomic, assign) NSTimeInterval foregroundDuration;
/// Cumulative background time
@property (nonatomic, assign) NSTimeInterval backgroundDuration;

/// Record the boot time node when the event occurred. Used to count the cumulative time of events
@property (nonatomic, assign) NSTimeInterval systemUpTime;

/// Used to record dynamic public properties, dynamic public properties need to be obtained in the current thread where the event occurs
@property (nonatomic, strong) NSDictionary *dynamicSuperProperties;

/// Used to document static public properties
@property (nonatomic, strong) NSDictionary *superProperties;

- (instancetype)initWithName:(NSString *)eventName;

@end

NS_ASSUME_NONNULL_END
