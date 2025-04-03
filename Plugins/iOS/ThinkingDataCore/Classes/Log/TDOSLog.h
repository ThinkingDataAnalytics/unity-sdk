//
//  TDOSLog.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/22.
//

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingDataCore/TDLogChannelProtocol.h>)
#import <ThinkingDataCore/TDLogChannelProtocol.h>
#else
#import "TDLogChannelProtocol.h"
#endif

#if __has_include(<ThinkingDataCore/TDLogConstant.h>)
#import <ThinkingDataCore/TDLogConstant.h>
#else
#import "TDLogConstant.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDOSLog : NSObject

+ (void)addLogConsumer:(id<TDLogChannleProtocol>)consumer;

+ (void)logMessage:(NSString *)message prefix:(nullable NSString *)prefix type:(TDLogType)type asynchronous:(BOOL)asynchronous;

@end

NS_ASSUME_NONNULL_END
