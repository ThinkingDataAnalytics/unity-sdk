//
//  TDMediator+Strategy.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/21.
//

#if __has_include(<ThinkingDataCore/TDMediator.h>)
#import <ThinkingDataCore/TDMediator.h>
#else
#import "TDMediator.h"
#endif

#if __has_include(<ThinkingDataCore/TDSettings.h>)
#import <ThinkingDataCore/TDSettings.h>
#else
#import "TDSettings.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDMediator (Strategy)

- (void)tdStrategyInitWithSettings:(nullable TDSettings *)settings;

- (nullable NSString *)tdStrategyGetSDKVersion;

@end

NS_ASSUME_NONNULL_END
