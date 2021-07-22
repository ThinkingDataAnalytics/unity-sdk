#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDK.h"

NS_ASSUME_NONNULL_BEGIN

#define TDLogDebug(message, ...)  TDLogWithType(TDLoggingLevelDebug, message, ##__VA_ARGS__)
#define TDLogInfo(message,  ...)  TDLogWithType(TDLoggingLevelInfo, message, ##__VA_ARGS__)
#define TDLogError(message, ...)  TDLogWithType(TDLoggingLevelError, message, ##__VA_ARGS__)

#define TDLogWithType(type, message, ...) \
{ \
if ([TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone && type <= [TDLogging sharedInstance].loggingLevel) \
{ \
[[TDLogging sharedInstance] logCallingFunction:type format:(message), ##__VA_ARGS__]; \
} \
}

@interface TDLogging : NSObject

@property (class, nonatomic, readonly) TDLogging *sharedInstance;
@property (assign, nonatomic) TDLoggingLevel loggingLevel;
- (void)logCallingFunction:(TDLoggingLevel)type format:(id)messageFormat, ...;

@end

NS_ASSUME_NONNULL_END
