//
//  TAAppExtensionAnalytic.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/5/25.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// key: event name in App Extension
extern NSString * const kTAAppExtensionEventName;
/// key: event properties in App Extension
extern NSString * const kTAAppExtensionEventProperties;
/// key: event properties
extern NSString * const kTAAppExtensionTime;
/// key: event properties
extern NSString * const kTAAppExtensionEventPropertiesSource;

/// App Extension 的事件收集
@interface TAAppExtensionAnalytic : NSObject

/// 初始化时间校准工具
/// @param timestamp 时间戳
+ (void)calibrateTime:(NSTimeInterval)timestamp;

/// 初始化时间校准工具
/// @param ntpServer NTP服务器地址
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;

/// 初始化一个事件采集对象
/// @param instanceName 事件采集对象的唯一标识
/// @param appGroupId 共享App Group ID
+ (TAAppExtensionAnalytic *)analyticWithInstanceName:(NSString * _Nonnull)instanceName appGroupId:(NSString * _Nonnull)appGroupId;

/// 写入事件
/// @param eventName 事件名称（须符合事件名规范）
/// @param properties 事件属性
/// @return 是否（YES/NO）写入成功
- (BOOL)writeEvent:(NSString * _Nonnull)eventName properties:(NSDictionary * _Nullable)properties;

/// 读取当前采集实例对应的所有缓存事件
- (NSArray *)readAllEvents;

/// 删除当前采集实例对应的所有缓存事件
- (BOOL)deleteEvents;

@end

NS_ASSUME_NONNULL_END
