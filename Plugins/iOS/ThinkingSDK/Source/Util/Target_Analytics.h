//
//  Target_Analytics.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2024/3/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Analytics : NSObject

- (void)Action_nativeInitWithParams:(nullable NSDictionary *)params;

- (nullable NSString *)Action_nativeGetAccountIdWithParams:(nullable NSDictionary *)params;

- (nullable NSString *)Action_nativeGetDistinctIdWithParams:(nullable NSDictionary *)params;

- (void)Action_nativeTrackEventWithParams:(nullable NSDictionary *)params;

- (void)Action_nativeUserSetWithParams:(nullable NSDictionary *)params;

- (nullable NSDictionary *)Action_nativeGetPresetPropertiesWithParams:(nullable NSDictionary *)params;

- (void)Action_nativeTrackDebugEventWithParams:(nullable NSDictionary *)params;

- (BOOL)Action_nativeGetEnableAutoPushWithParams:(nullable NSDictionary *)params;

- (nullable NSArray<NSString *> *)Action_nativeGetAllAppIdsWithParams:(nullable NSDictionary *)params;

- (nullable NSString *)Action_nativeGetSDKVersionWithParams:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
