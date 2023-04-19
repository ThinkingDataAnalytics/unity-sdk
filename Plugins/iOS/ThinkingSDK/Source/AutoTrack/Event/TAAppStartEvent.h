//
//  TAAppStartEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TAAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAppStartEvent : TAAutoTrackEvent
@property (nonatomic, copy) NSString *startReason;
@property (nonatomic, assign) BOOL resumeFromBackground;


@end

NS_ASSUME_NONNULL_END
