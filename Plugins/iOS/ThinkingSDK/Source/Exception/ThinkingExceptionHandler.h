#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingExceptionHandler : NSObject

+ (void)start;

+ (void)trackCrashWithMessage:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
