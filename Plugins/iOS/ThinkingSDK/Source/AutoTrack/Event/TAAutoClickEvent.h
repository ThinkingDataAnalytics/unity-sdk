//
//  TAAutoClickEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TAAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAAutoClickEvent : TAAutoTrackEvent
@property (nonatomic, copy) NSString *elementId;
@property (nonatomic, copy) NSString *elementContent;
@property (nonatomic, copy) NSString *elementType;
@property (nonatomic, copy) NSString *elementPosition;
@property (nonatomic, copy) NSString *pageTitle;
@property (nonatomic, copy) NSString *screenName;

@end

NS_ASSUME_NONNULL_END
