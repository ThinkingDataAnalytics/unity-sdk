#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingExceptionHandler : NSObject

@property (nonatomic, strong) NSHashTable *thinkingAnalyticsSDKInstances;

@property (nonatomic) NSUncaughtExceptionHandler *td_lastExceptionHandler;

@property (nonatomic, unsafe_unretained) struct sigaction *td_signalHandlers;

+ (instancetype)sharedHandler;

- (void)addThinkingInstance:(ThinkingAnalyticsSDK *)instance;

@end

NS_ASSUME_NONNULL_END
