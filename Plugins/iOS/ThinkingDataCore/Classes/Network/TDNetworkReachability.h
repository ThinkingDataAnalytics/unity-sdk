//
//  TDNetworkReachability.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDNetworkReachability : NSObject

+ (instancetype)shareInstance;

- (void)startMonitoring;

- (void)stopMonitoring;

- (NSString *)networkState;

- (nullable NSString *)carrier;

@end

NS_ASSUME_NONNULL_END
