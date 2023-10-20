//
//  TAPushClickEvent.h
//  ThinkingSDK
//
//  Created by liulongbing on 2023/5/31.
//
#import "TAAutoTrackEvent.h"
NS_ASSUME_NONNULL_BEGIN

@interface TAPushClickEvent : TAAutoTrackEvent

@property (nonatomic, strong) NSDictionary *ops;

@end

NS_ASSUME_NONNULL_END
