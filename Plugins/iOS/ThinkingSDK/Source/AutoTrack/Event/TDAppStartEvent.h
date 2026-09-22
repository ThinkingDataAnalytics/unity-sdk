//
//  TDAppStartEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TDAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAppStartEvent : TDAutoTrackEvent
@property (nonatomic, copy) NSString *startReason;
@property (nonatomic, assign) BOOL resumeFromBackground;


@end

NS_ASSUME_NONNULL_END
