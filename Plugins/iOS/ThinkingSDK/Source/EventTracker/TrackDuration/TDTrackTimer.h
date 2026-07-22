//
//  TATrackTimer.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDTrackTimer : NSObject

- (void)trackEvent:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime;

- (void)enterForegroundWithSystemUptime:(NSTimeInterval)systemUptime;

- (void)enterBackgroundWithSystemUptime:(NSTimeInterval)systemUptime;

- (NSTimeInterval)foregroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

- (NSTimeInterval)backgroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

- (void)removeEvent:(NSString * _Nonnull)eventName;

- (BOOL)isExistEvent:(NSString * _Nonnull)eventName;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
