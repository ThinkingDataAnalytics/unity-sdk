//
//  TDAutoPageViewEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TDAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAutoPageViewEvent : TDAutoTrackEvent
@property (nonatomic, copy) NSString *pageUrl;
@property (nonatomic, copy) NSString *referrer;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
