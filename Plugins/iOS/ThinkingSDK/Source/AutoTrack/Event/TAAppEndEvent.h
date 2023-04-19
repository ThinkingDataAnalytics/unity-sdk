//
//  TAAppEndEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TAAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAppEndEvent : TAAutoTrackEvent
@property (nonatomic, copy) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
