#import <Foundation/Foundation.h>
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

#define TDLogDebug(message, ...)  TDLogWithType(TDLoggingLevelDebug, message, ##__VA_ARGS__)
#define TDLogInfo(message,  ...)  TDLogWithType(TDLoggingLevelInfo, message, ##__VA_ARGS__)
#define TDLogError(message, ...)  TDLogWithType(TDLoggingLevelError, message, ##__VA_ARGS__)

#define TDLogWithType(type, message, ...) \
{ \
[[TDLogging sharedInstance] logCallingFunction:type format:(message), ##__VA_ARGS__]; \
}

@interface TDLogging : NSObject
@property (assign, nonatomic) BOOL enableLog;

+ (instancetype)sharedInstance;

- (void)logCallingFunction:(TDLoggingLevel)type format:(id)messageFormat, ...;

@end

NS_ASSUME_NONNULL_END
