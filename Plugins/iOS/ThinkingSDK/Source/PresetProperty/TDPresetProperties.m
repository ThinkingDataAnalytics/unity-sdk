//
//  TDPresetProperties.m
//  ThinkingSDK
//
//  Created by huangdiao on 2021/5/25.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDPresetProperties.h"

static const NSString *kTDPresetBundleId = @"#bundle_id";
static const NSString *kTDPresetCarrier = @"#carrier";
static const NSString *kTDPresetDeviceId = @"#device_id";
static const NSString *kTDPresetDeviceModel = @"#device_model";
static const NSString *kTDPresetManufacturer = @"#manufacturer";
static const NSString *kTDPresetNetworkType = @"#network_type";
static const NSString *kTDPresetOSName = @"#os";
static const NSString *kTDPresetOSVersion = @"#os_version";
static const NSString *kTDPresetScreenHeight = @"#screen_height";
static const NSString *kTDPresetScreenWidth = @"#screen_width";
static const NSString *kTDPresetSystemLanguage = @"#system_language";
static const NSString *kTDPresetZoneOffset = @"#zone_offset";
static const NSString *kTDPresetAppVersion = @"#app_version";
static const NSString *kTDPresetInstallTime = @"#install_time";
static const NSString *kTDPresetIsSimulator = @"#simulator";
static const NSString *kTDPresetRam = @"#ram";
static const NSString *kTDPresetDisk = @"#disk";
static const NSString *kTDPresetFps  = @"#fps";
static const NSString *kTDPresetDeviceType = @"#device_type";

@interface TDPresetProperties ()

@property (nonatomic, copy, readwrite) NSString *bundle_id;
@property (nonatomic, copy, readwrite) NSString *carrier;
@property (nonatomic, copy, readwrite) NSString *device_id;
@property (nonatomic, copy, readwrite) NSString *device_model;
@property (nonatomic, copy, readwrite) NSString *manufacturer;
@property (nonatomic, copy, readwrite) NSString *network_type;
@property (nonatomic, copy, readwrite) NSString *os;
@property (nonatomic, copy, readwrite) NSString *os_version;
@property (nonatomic, strong, readwrite) NSNumber *screen_height;
@property (nonatomic, strong, readwrite) NSNumber *screen_width;
@property (nonatomic, copy, readwrite) NSString *system_language;
@property (nonatomic, copy, readwrite) NSNumber *zone_offset;
@property (nonatomic, copy, readwrite) NSString *appVersion;
@property (nonatomic, copy, readwrite) NSString *install_time;
@property (nonatomic, strong, readwrite) NSNumber *isSimulator;
@property (nonatomic, copy, readwrite) NSString *ram;
@property (nonatomic, copy, readwrite) NSString *disk;
@property (nonatomic, strong, readwrite) NSNumber *fps;
@property (nonatomic, copy, readwrite) NSString *deviceType;

@end

@implementation TDPresetProperties

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.bundle_id = dict[kTDPresetBundleId];
        self.carrier = dict[kTDPresetCarrier];
        self.device_id = dict[kTDPresetDeviceId];
        self.device_model = dict[kTDPresetDeviceModel];
        self.manufacturer = dict[kTDPresetManufacturer];
        self.network_type = dict[kTDPresetNetworkType];
        self.os = dict[kTDPresetOSName];
        self.os_version = dict[kTDPresetOSVersion];
        self.screen_height = dict[kTDPresetScreenHeight];
        self.screen_width = dict[kTDPresetScreenWidth];
        self.system_language = dict[kTDPresetSystemLanguage];
        self.zone_offset = dict[kTDPresetZoneOffset];
        self.appVersion = dict[kTDPresetAppVersion];
        self.install_time = dict[kTDPresetInstallTime];
        self.isSimulator = dict[kTDPresetIsSimulator];
        self.ram = dict[kTDPresetRam];
        self.disk = dict[kTDPresetDisk];
        self.fps = dict[kTDPresetFps];
        self.deviceType = dict[kTDPresetDeviceType];
    }
    return self;
}

- (NSDictionary *)toEventPresetProperties {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.bundle_id) {
        dict[kTDPresetBundleId] = self.bundle_id;
    }
    if (self.carrier) {
        dict[kTDPresetCarrier] = self.carrier;
    }
    if (self.device_id) {
        dict[kTDPresetDeviceId] = self.device_id;
    }
    if (self.device_model) {
        dict[kTDPresetDeviceModel] = self.device_model;
    }
    if (self.manufacturer) {
        dict[kTDPresetManufacturer] = self.manufacturer;
    }
    if (self.network_type) {
        dict[kTDPresetNetworkType] = self.network_type;
    }
    if (self.os) {
        dict[kTDPresetOSName] = self.os;
    }
    if (self.os_version) {
        dict[kTDPresetOSVersion] = self.os_version;
    }
    if (self.screen_height) {
        dict[kTDPresetScreenHeight] = self.screen_height;
    }
    if (self.screen_width) {
        dict[kTDPresetScreenWidth] = self.screen_width;
    }
    if (self.system_language) {
        dict[kTDPresetSystemLanguage] = self.system_language;
    }
    if (self.zone_offset) {
        dict[kTDPresetZoneOffset] = self.zone_offset;
    }
    if (self.appVersion) {
        dict[kTDPresetAppVersion] = self.appVersion;
    }
    if (self.install_time) {
        dict[kTDPresetInstallTime] = self.install_time;
    }
    if (self.isSimulator) {
        dict[kTDPresetIsSimulator] = self.isSimulator;
    }
    if (self.ram) {
        dict[kTDPresetRam] = self.ram;
    }
    if (self.disk) {
        dict[kTDPresetDisk] = self.disk;
    }
    if (self.fps) {
        dict[kTDPresetFps] = self.fps;
    }
    if (self.deviceType) {
        dict[kTDPresetDeviceType] = self.deviceType;
    }

    return dict;
}

@end
