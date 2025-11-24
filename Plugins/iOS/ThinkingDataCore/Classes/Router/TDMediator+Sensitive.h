//
//  TDMediator+Sensitive.h
//  ThinkingDataCore
//
//  Created by liulongbing on 2025/5/28.
//

#if __has_include(<ThinkingDataCore/TDMediator.h>)
#import <ThinkingDataCore/TDMediator.h>
#else
#import "TDMediator.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kTDMediatorTargetSensitive;

@interface TDMediator (Sensitive)

- (nullable NSDictionary *)tdGetSensitiveProperties;

@end

NS_ASSUME_NONNULL_END
