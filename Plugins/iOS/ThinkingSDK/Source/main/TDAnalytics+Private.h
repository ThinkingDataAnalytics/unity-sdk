//
//  TDAnalytics+Private.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2024/5/31.
//

#if __has_include(<ThinkingSDK/TDAnalytics.h>)
#import <ThinkingSDK/TDAnalytics.h>
#else
#import "TDAnalytics.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalytics (Private)

+ (void)trackDebug:(NSString *)eventName properties:(nullable NSDictionary *)properties appId:(NSString * _Nullable)appId;

@end

NS_ASSUME_NONNULL_END
