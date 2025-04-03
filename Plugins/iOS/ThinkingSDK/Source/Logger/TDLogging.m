#import "TDLogging.h"

#if __has_include(<ThinkingDataCore/TDOSLog.h>)
#import <ThinkingDataCore/TDOSLog.h>
#else
#import "TDOSLog.h"
#endif

@implementation TDLogging

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)logCallingFunction:(TDLoggingLevel)type format:(id)messageFormat, ... {
    if (messageFormat) {
        va_list formatList;
        va_start(formatList, messageFormat);
        NSString *formattedMessage = [[NSString alloc] initWithFormat:messageFormat arguments:formatList];
        va_end(formatList);
        
        TDLogType logType = TDLogTypeOff;
        switch (type) {
            case TDLoggingLevelNone:
                logType = TDLogTypeOff;
                break;
            case TDLoggingLevelError:
                logType = TDLogTypeError;
                break;
            case TDLoggingLevelWarning:
                logType = TDLogTypeWarning;
                break;
            case TDLoggingLevelInfo:
                logType = TDLogTypeInfo;
                break;
            case TDLoggingLevelDebug:
                logType = TDLogTypeDebug;
                break;
            default:
                logType = TDLogTypeOff;
                break;
        }
        NSString *prefix = @"ThinkingData";
        [TDOSLog logMessage:formattedMessage prefix:prefix type:logType asynchronous:YES];
    }
}

@end

