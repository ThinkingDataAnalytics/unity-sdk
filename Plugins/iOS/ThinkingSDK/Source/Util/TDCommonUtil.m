//
//  TDCommonUtil.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/11.
//

#import "TDCommonUtil.h"
#import <sys/sysctl.h>

@implementation TDCommonUtil

+ (NSString *)string:(NSString *)string {
    if ([string isKindOfClass:[NSString class]] && string.length) {
        return string;
    } else {
        return @"";
    }
}

+ (NSDictionary *)dictionary:(NSDictionary *)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]] && dic.allKeys.count) {
        return dic;
    } else {
        return @{};
    }
}

+ (NSTimeInterval)uptime
{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);

    struct timeval now;
    struct timezone tz;
    gettimeofday(&now, &tz);

    double uptime = -1;

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0)
    {
        uptime = now.tv_sec - boottime.tv_sec;
        uptime += (double)(now.tv_usec - boottime.tv_usec) / 1000000.0;
    }
    return uptime;
}

@end
