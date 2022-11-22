#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingExceptionHandler : NSObject
// 多实例
@property (nonatomic, strong) NSHashTable *thinkingAnalyticsSDKInstances;
// 保留上一次的ExceptionHandler，在操作完成后需要将异常向后传递
@property (nonatomic) NSUncaughtExceptionHandler *td_lastExceptionHandler;
// mach 信号异常
@property (nonatomic, unsafe_unretained) struct sigaction *td_signalHandlers;

+ (instancetype)sharedHandler;

- (void)addThinkingInstance:(ThinkingAnalyticsSDK *)instance;

@end

NS_ASSUME_NONNULL_END
