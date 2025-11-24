//
//  TDCoreLog.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/7/17.
//

#import "TDCoreLog.h"
#import "TDOSLog.h"

static BOOL _logOn = YES;

@implementation TDCoreLog

+ (void)enableLog:(BOOL)enable {
    _logOn = enable;
}

+ (void)printLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    TDLogType type = _logOn ? TDLogTypeInfo : TDLogTypeOff;
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *output = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        NSString *prefix = @"TDCore";
        [TDOSLog logMessage:output prefix:prefix type:type asynchronous:YES];
    }
}

@end
