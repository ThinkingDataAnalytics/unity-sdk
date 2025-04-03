//
//  TDRunTime.m
//  ThinkingSDK
//
//  Created by wwango on 2021/12/30.
//

#import "TDRunTime.h"

#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDRunTime

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
+ (NSString *)getAppLaunchReason {
    // start reason
    Class cls = NSClassFromString(@"TDAppLaunchReason");
    id appLaunch = [cls performSelector:@selector(sharedInstance)];
    
    if (appLaunch && [appLaunch respondsToSelector:@selector(appLaunchParams)] && ![TDCorePresetDisableConfig disableStartReason]) {
        NSDictionary *startReason = [appLaunch performSelector:@selector(appLaunchParams)];
        NSString *url = startReason[@"url"];
        NSDictionary *data = startReason[@"data"];
        if (url.length == 0 && data.allKeys.count == 0) {
            return @"";
        } else {
            if (data.allKeys.count == 0) {
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
