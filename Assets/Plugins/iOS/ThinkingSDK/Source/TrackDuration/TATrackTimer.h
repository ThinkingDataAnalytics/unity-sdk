//
//  TATrackTimer.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TATrackTimer : NSObject

/// 开始记录某个事件的时间
- (void)trackEvent:(NSString *)eventName;

/// app 进入前台，更新时间
- (void)enterForeground;

/// app 进入后台，更新时间
- (void)enterBackground;

/// 获取某个事件对应的前台累计时长
/// @param eventName 事件名
/// @param isActive  app是否在前台
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (NSTimeInterval)foregroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

/// 获取某个事件对应的后台累计时长
/// @param eventName 事件名
/// @param isActive  app是否在前台
/// @param systemUptime  传入一个截止的时间点（系统开机时长）
- (NSTimeInterval)backgroundDurationOfEvent:(NSString * _Nonnull)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime;

/// 删除某个事件的时间统计
/// @param eventName 事件名
- (void)removeEvent:(NSString * _Nonnull)eventName;

/// 是否包含某个事件
/// @param eventName 事件名字
- (BOOL)isExistEvent:(NSString * _Nonnull)eventName;

/// 清空所有事件的时间统计
- (void)clear;

@end

NS_ASSUME_NONNULL_END
