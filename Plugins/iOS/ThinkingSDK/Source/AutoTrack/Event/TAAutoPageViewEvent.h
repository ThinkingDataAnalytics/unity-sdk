//
//  TAAutoPageViewEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TAAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoPageViewEvent : TAAutoTrackEvent
@property (nonatomic, copy) NSString *pageUrl;
@property (nonatomic, copy) NSString *referrer;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
