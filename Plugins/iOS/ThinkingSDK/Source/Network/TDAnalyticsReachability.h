//
//  TDAnalyticsReachability.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalyticsReachability : NSObject

+ (ThinkingNetworkType)convertNetworkType:(NSString *)networkType;

+ (instancetype)shareInstance;

- (void)startMonitoring;

- (void)stopMonitoring;

- (NSString *)networkState;


@end

NS_ASSUME_NONNULL_END
