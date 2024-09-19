//
//  TDAppEndEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TDAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAppEndEvent : TDAutoTrackEvent
@property (nonatomic, copy) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
