#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDConstant.h>)
#import <ThinkingSDK/TDConstant.h>
#else
#import "TDConstant.h"
#endif

@class TDLogMessage;
@protocol TDLogger;

NS_ASSUME_NONNULL_BEGIN

@interface TDOSLog : NSObject

+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
       type:(TDLoggingLevel)type;

@end

@protocol TDLogger <NSObject>

- (void)logMessage:(TDLogMessage *)logMessage;

@optional

@property (nonatomic, strong, readonly) dispatch_queue_t loggerQueue;

@end

@interface TDLogMessage : NSObject 

- (instancetype)initWithMessage:(NSString *)message
                           type:(TDLoggingLevel)type;

@end

@interface TDAbstractLogger : NSObject <TDLogger>

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
