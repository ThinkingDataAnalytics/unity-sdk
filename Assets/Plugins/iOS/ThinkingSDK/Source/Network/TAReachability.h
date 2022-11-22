//
//  TAReachability.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAReachability : NSObject

/// 获取网络状态监听类
+ (instancetype)shareInstance;

/// 开启网络状态监听
- (void)startMonitoring;

/// 停止网络状态监听
- (void)stopMonitoring;

/// 获取网络状态
- (NSString *)networkState;

@end

NS_ASSUME_NONNULL_END
