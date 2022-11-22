//
//  TDRunTime.m
//  ThinkingSDK
//
//  Created by wwango on 2021/12/30.
//

#import "TDRunTime.h"
#import "TDJSONUtil.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TDRunTime

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
+ (NSString *)getAppLaunchReason {
    // 启动原因
    Class cls = NSClassFromString(@"TDAppLaunchReason");
    id appLaunch = [cls performSelector:@selector(sharedInstance)];
    
    if (appLaunch &&
        [appLaunch respondsToSelector:@selector(appLaunchParams)] &&
        !TDPresetProperties.disableStartReason)
    {
        NSDictionary *startReason = [appLaunch performSelector:@selector(appLaunchParams)];
        NSString *url = startReason[@"url"];
        NSDictionary *data = startReason[@"data"];
        if (url.length == 0 && data.allKeys.count == 0) {
            return @"";
        } else {
            if (data.allKeys.count == 0) {
                // data没有值的时候，将data字段赋值空字符串
                startReason = @{@"url":url, @"data":@""};
            }
            NSString *startReasonString = [TDJSONUtil JSONStringForObject:startReason];
            if (startReasonString && startReasonString.length) {
                return startReasonString;
            }
        }
    }
    return @"";
}

#pragma clang diagnostic pop

@end
