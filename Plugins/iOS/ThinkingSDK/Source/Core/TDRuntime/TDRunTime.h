//
//  TDRunTime.h
//  ThinkingSDK
//
//  Created by wwango on 2021/12/30.
//  用于插件化时，通过反射方式获取类名、获取参数
//  此类是线程不安全的，使用时注意多线程问题

/**
 动态获取类名：
 TDAppLaunchReason  启动原因
 TDPresetProperties，预置属性， 此模块需要解耦
 
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDRunTime : NSObject

// 启动原因
+ (NSString *)getAppLaunchReason;

@end

NS_ASSUME_NONNULL_END
