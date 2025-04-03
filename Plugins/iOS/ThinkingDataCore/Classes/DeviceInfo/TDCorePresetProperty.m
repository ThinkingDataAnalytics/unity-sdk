//
//  TDCorePresetProperty.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/26.
//

#import "TDCorePresetProperty.h"
#import "TDCoreDeviceInfo.h"
#import "TDCorePresetDisableConfig.h"

@implementation TDCorePresetProperty

+ (NSDictionary *)staticProperties {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (![TDCorePresetDisableConfig disableBundleId]) {
        NSString *value = [TDCoreDeviceInfo bundleId];
        if (value) {
            dict[@"#bundle_id"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableInstallTime]) {
        NSDate *value = [TDCoreDeviceInfo installTime];
        if (value) {
            dict[@"#install_time"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableDeviceId]) {
        NSString *value = [TDCoreDeviceInfo deviceId];
        if (value) {
            dict[@"#device_id"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableAppVersion]) {
        NSString *value = [TDCoreDeviceInfo appVersion];
        if (value) {
            dict[@"#app_version"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableOs]) {
        NSString *value = [TDCoreDeviceInfo os];
        if (value) {
            dict[@"#os"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableOsVersion]) {
        NSString *value = [TDCoreDeviceInfo osVersion];
        if (value) {
            dict[@"#os_version"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableDeviceModel]) {
        NSString *value = [TDCoreDeviceInfo deviceModel];
        if (value) {
            dict[@"#device_model"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableDeviceType]) {
        NSString *value = [TDCoreDeviceInfo deviceType];
        if (value) {
            dict[@"#device_type"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableManufacturer]) {
        NSString *value = [TDCoreDeviceInfo manufacturer];
        if (value) {
            dict[@"#manufacturer"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableSimulator]) {
        dict[@"#simulator"] = [TDCoreDeviceInfo isSimulator] ? @(YES) : @(NO);
    }
#if TARGET_OS_IOS
    
    if (![TDCorePresetDisableConfig disableScreenWidth]) {
        NSNumber *value = [TDCoreDeviceInfo screenWidth];
        if (value) {
            dict[@"#screen_width"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableScreenHeight]) {
        NSNumber *value = [TDCoreDeviceInfo screenHeight];
        if (value) {
            dict[@"#screen_height"] = value;
        }
    }
#endif
    return dict;
}

+ (NSDictionary *)dynamicProperties {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
        
    if (![TDCorePresetDisableConfig disableRAM]) {
        NSString *value = [TDCoreDeviceInfo ram];
        if (value) {
            mutableDict[@"#ram"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableDisk]) {
        NSString *value = [TDCoreDeviceInfo disk];
        if (value) {
            mutableDict[@"#disk"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableSystemLanguage]) {
        NSString *value = [TDCoreDeviceInfo systemLanguage];
        if (value) {
            mutableDict[@"#system_language"] = value;
        }
    }
#if TARGET_OS_IOS
    if (![TDCorePresetDisableConfig disableCarrier]) {
        NSString *value = [TDCoreDeviceInfo carrier];
        if (value) {
            mutableDict[@"#carrier"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableNetworkType]) {
        NSString *value = [TDCoreDeviceInfo networkType];
        if (value) {
            mutableDict[@"#network_type"] = value;
        }
    }
    if (![TDCorePresetDisableConfig disableFPS]) {
        NSNumber *value = [TDCoreDeviceInfo fps];
        if (value) {
            mutableDict[@"#fps"] = value;
        }
    }
#endif
    return mutableDict;
}

+ (NSDictionary *)allPresetProperties {
    NSDictionary *staticDict = [self staticProperties];
    NSDictionary *dynamicDict = [self dynamicProperties];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict addEntriesFromDictionary:staticDict];
    [dict addEntriesFromDictionary:dynamicDict];
    return dict;
}

@end
