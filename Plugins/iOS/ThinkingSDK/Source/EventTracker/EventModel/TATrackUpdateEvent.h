//
//  TATrackUpdateEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TATrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TATrackUpdateEvent : TATrackEvent

@property (nonatomic, copy) NSString *eventId;

@end

NS_ASSUME_NONNULL_END
