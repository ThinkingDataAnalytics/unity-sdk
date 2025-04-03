//
//  TDLogChannelConsole.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/22.
//

#import "TDLogChannelConsole.h"
#import <os/log.h>

@interface TDLogChannelConsole ()
@property (strong, nonatomic) os_log_t logger;

@end

@implementation TDLogChannelConsole

- (instancetype)init
{
    self = [super init];
    if (self) {
#ifdef __IPHONE_10_0
        self.logger = os_log_create("cn.thinkingdata.analytics.log", "ThinkingData");
#endif
    }
    return self;
}

- (void)printMessage:(NSString *)message type:(TDLogType)type {
    if (message == nil) {
        return;
    }

#ifdef __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        const char *msg = [message UTF8String];
        os_log_t logger = self.logger;
        switch (type) {
            case TDLogTypeDebug:
                os_log_debug(logger, "%{public}s", msg);
                break;
            case TDLogTypeInfo:
                os_log_info(logger, "%{public}s", msg);
                break;
            case TDLogTypeWarning:
                os_log_error(logger, "%{public}s", msg);
                break;
            case TDLogTypeError:
                os_log_error(logger, "%{public}s", msg);
                break;
            case TDLogTypeOff:
            default:
                break;
        }
    }
#else
    NSLog(@"%@", message);
#endif
}


@end
