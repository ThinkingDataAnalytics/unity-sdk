//
//  TDAnalyticsPresetProperty.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2024/5/27.
//

#import "TDAnalyticsPresetProperty.h"
#import "TDDeviceInfo.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

#if __has_include(<ThinkingDataCore/NSDate+TDCore.h>)
#import <ThinkingDataCore/NSDate+TDCore.h>
#else
#import "NSDate+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/NSString+TDCore.h>)
#import <ThinkingDataCore/NSString+TDCore.h>
#else
#import "NSString+TDCore.h"
#endif

#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDAnalyticsPresetProperty

+ (NSDictionary *)propertiesWithAppId:(NSString *)appId {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    if (![TDCorePresetDisableConfig disableLib]) {
        NSString *value = [[TDDeviceInfo sharedManager] libName];
        if (value) {
            mutableDict[@"#lib"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableLibVersion]) {
        NSString *value = [[TDDeviceInfo sharedManager] libVersion];
        if (value) {
            mutableDict[@"#lib_version"] = value;
        }
    }
    
    if (![NSString td_isEmpty:appId]) {
        ThinkingAnalyticsSDK *sdk = [ThinkingAnalyticsSDK instanceWithAppid:appId];
        double offset = [[NSDate date] td_timeZoneOffset:sdk.config.defaultTimeZone ?: [NSTimeZone localTimeZone]];
        [mutableDict setObject:@(offset) forKey:@"#zone_offset"];
    }
    
    return mutableDict;
}

@end
