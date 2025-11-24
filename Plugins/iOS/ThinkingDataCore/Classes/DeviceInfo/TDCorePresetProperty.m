//
//  TDCorePresetProperty.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/26.
//

#import "TDCorePresetProperty.h"
#import "TDCoreDeviceInfo.h"
#import "TDCorePresetDisableConfig.h"

static NSString *g_bundleId = nil;
static NSDate *g_installTime = nil;
static NSString *g_deviceId = nil;
static NSString *g_appVersion = nil;
static NSString *g_os = nil;
static NSString *g_osVersion = nil;
static NSString *g_deviceModel = nil;
static NSString *g_deviceType = nil;
static NSString *g_manufacturer = nil;
static NSNumber *g_isSimulator = nil;
#if TARGET_OS_IOS
static NSNumber *g_screenWidth = nil;
static NSNumber *g_screenHeight = nil;
#endif

@implementation TDCorePresetProperty

+ (NSDictionary *)staticProperties {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (![TDCorePresetDisableConfig disableBundleId]) {
        if (g_bundleId == nil) {
            g_bundleId = [TDCoreDeviceInfo bundleId];
        }
        dict[@"#bundle_id"] = g_bundleId;
    }
    if (![TDCorePresetDisableConfig disableInstallTime]) {
        if (g_installTime == nil) {
            g_installTime = [TDCoreDeviceInfo installTime];
        }
        dict[@"#install_time"] = g_installTime;
    }
    if (![TDCorePresetDisableConfig disableDeviceId]) {
        if (g_deviceId == nil) {
            g_deviceId = [TDCoreDeviceInfo deviceId];
        }
        dict[@"#device_id"] = g_deviceId;
    }
    if (![TDCorePresetDisableConfig disableAppVersion]) {
        if (g_appVersion == nil) {
            g_appVersion = [TDCoreDeviceInfo appVersion];
        }
        dict[@"#app_version"] = g_appVersion;
    }
    if (![TDCorePresetDisableConfig disableOs]) {
        if (g_os == nil) {
            g_os = [TDCoreDeviceInfo os];
        }
        dict[@"#os"] = g_os;
    }
    if (![TDCorePresetDisableConfig disableOsVersion]) {
        if (g_osVersion == nil) {
            g_osVersion = [TDCoreDeviceInfo osVersion];
        }
        dict[@"#os_version"] = g_osVersion;
    }
    if (![TDCorePresetDisableConfig disableDeviceModel]) {
        if (g_deviceModel == nil) {
            g_deviceModel = [TDCoreDeviceInfo deviceModel];
        }
        dict[@"#device_model"] = g_deviceModel;
    }
    if (![TDCorePresetDisableConfig disableDeviceType]) {
        if (g_deviceType == nil) {
            g_deviceType = [TDCoreDeviceInfo deviceType];
        }
        dict[@"#device_type"] = g_deviceType;
    }
    if (![TDCorePresetDisableConfig disableManufacturer]) {
        if (g_manufacturer == nil) {
            g_manufacturer = [TDCoreDeviceInfo manufacturer];
        }
        dict[@"#manufacturer"] = g_manufacturer;
    }
    if (![TDCorePresetDisableConfig disableSimulator]) {
        if (g_isSimulator == nil) {
            g_isSimulator = [TDCoreDeviceInfo isSimulator] ? @(YES) : @(NO);
        }
        dict[@"#simulator"] = g_isSimulator;
    }
#if TARGET_OS_IOS
    
    if (![TDCorePresetDisableConfig disableScreenWidth]) {
        if (g_screenWidth == nil) {
            g_screenWidth = [TDCoreDeviceInfo screenWidth];
        }
        dict[@"#screen_width"] = g_screenWidth;
    }
    if (![TDCorePresetDisableConfig disableScreenHeight]) {
        if (g_screenHeight == nil) {
            g_screenHeight = [TDCoreDeviceInfo screenHeight];
        }
        dict[@"#screen_height"] = g_screenHeight;
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
