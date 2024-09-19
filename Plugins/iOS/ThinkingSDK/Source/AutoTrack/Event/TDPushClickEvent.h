//
//  TAPushClickEvent.h
//  ThinkingSDK
//
//  Created by liulongbing on 2023/5/31.
//
#import "TDAutoTrackEvent.h"
NS_ASSUME_NONNULL_BEGIN

@interface TDPushClickEvent : TDAutoTrackEvent

@property (nonatomic, strong) NSDictionary *ops;

@end

NS_ASSUME_NONNULL_END
