//
//  TDCorePresetDisableConfig.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/25.
//

#import "TDCorePresetDisableConfig.h"

static BOOL _td_disableOpsReceiptProperties;
static BOOL _td_disableStartReason;
static BOOL _td_disableDisk;
static BOOL _td_disableRAM;
static BOOL _td_disableFPS;
static BOOL _td_disableSimulator;
static BOOL _td_disableAppVersion;
static BOOL _td_disableOsVersion;
static BOOL _td_disableManufacturer;
static BOOL _td_disableDeviceModel;
static BOOL _td_disableScreenHeight;
static BOOL _td_disableScreenWidth;
static BOOL _td_disableCarrier;
static BOOL _td_disableDeviceId;
static BOOL _td_disableSystemLanguage;
static BOOL _td_disableLib;
static BOOL _td_disableLibVersion;
static BOOL _td_disableBundleId;
static BOOL _td_disableOs;
static BOOL _td_disableInstallTime;
static BOOL _td_disableDeviceType;
static BOOL _td_disableSessionID;
static BOOL _td_disableCalibratedTime;

static BOOL _td_disableNetworkType;
static BOOL _td_disableZoneOffset;
static BOOL _td_disableDuration;
static BOOL _td_disableBackgroundDuration;
static BOOL _td_disableAppCrashedReason;
static BOOL _td_disableResumeFromBackground;
static BOOL _td_disableElementId;
static BOOL _td_disableElementType;
static BOOL _td_disableElementContent;
static BOOL _td_disableElementPosition;
static BOOL _td_disableElementSelector;
static BOOL _td_disableScreenName;
static BOOL _td_disableTitle;
static BOOL _td_disableUrl;
static BOOL _td_disableReferrer;

// - 禁用功能并过滤字段拼接
static const NSString *kTDPresentOpsReceiptProperties = @"#ops_receipt_properties";
static const NSString *kTDStartReason  = @"#start_reason";
static const NSString *kTDPerformanceRAM  = @"#ram";
static const NSString *kTDPerformanceDISK = @"#disk";
static const NSString *kTDPerformanceSIM  = @"#simulator";
static const NSString *kTDPerformanceFPS  = @"#fps";
static const NSString *kTDPresentAppVersion  = @"#app_version";
static const NSString *kTDPresentOsVersion = @"#os_version";
static const NSString *kTDPresentManufacturer  = @"#manufacturer";
static const NSString *kTDPresentDeviceModel  = @"#device_model";
static const NSString *kTDPresentScreenHeight  = @"#screen_height";
static const NSString *kTDPresentScreenWidth  = @"#screen_width";
static const NSString *kTDPresentCarrier  = @"#carrier";
static const NSString *kTDPresentDeviceId  = @"#device_id";
static const NSString *kTDPresentSystemLanguage  = @"#system_language";
static const NSString *kTDPresentLib  = @"#lib";
static const NSString *kTDPresentLibVersion  = @"#lib_version";
static const NSString *kTDPresentOs  = @"#os";
static const NSString *kTDPresentBundleId  = @"#bundle_id";
static const NSString *kTDPresentInstallTime  = @"#install_time";
static const NSString *kTDPresentDeviceType = @"#device_type";
static const NSString *kTDPresentSessionID  = @"#session_id";
static const NSString *kTDPresentCalibratedTime = @"#time_calibration";

// - 只过滤字段
static const NSString *kTDPresentNETWORKTYPE = @"#network_type";
static const NSString *kTDPresentZONEOFFSET = @"#zone_offset";
static const NSString *kTDPresentDURATION = @"#duration";
static const NSString *kTDPresentBACKGROUNDDURATION = @"#background_duration";
static const NSString *kTDPresentCRASHREASON = @"#app_crashed_reason";
static const NSString *kTDPresentRESUMEFROMBACKGROUND = @"#resume_from_background";
static const NSString *kTDPresentELEMENTID = @"#element_id";
static const NSString *kTDPresentELEMENTTYPE = @"#element_type";
static const NSString *kTDPresentELEMENTCONTENT = @"#element_content";
static const NSString *kTDPresentELEMENTPOSITION = @"#element_position";
static const NSString *kTDPresentELEMENTSELECTOR = @"#element_selector";
static const NSString *kTDPresentSCREENNAME = @"#screen_name";
static const NSString *kTDPresentTITLE = @"#title";
static const NSString *kTDPresentURL = @"#url";
static const NSString *kTDPresentREFERRER = @"#referrer";

#define TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY @"TDDisPresetProperties"

@implementation TDCorePresetDisableConfig

static NSMutableArray *__td_disPresetProperties;

+ (void)initialize {
    [self loadDisPresetProperties];
}

+ (NSArray *)loadDisPresetProperties {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSArray *disPresetProperties = (NSArray *)[[[NSBundle mainBundle] infoDictionary] objectForKey:TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY];

        if (disPresetProperties && disPresetProperties.count) {
            __td_disPresetProperties = [NSMutableArray arrayWithArray:disPresetProperties];
            
            if ([__td_disPresetProperties containsObject:kTDPresentZONEOFFSET]) {
                [__td_disPresetProperties removeObject:kTDPresentZONEOFFSET];
            }

            _td_disableStartReason = [__td_disPresetProperties containsObject:kTDStartReason];
            _td_disableDisk        = [__td_disPresetProperties containsObject:kTDPerformanceDISK];
            _td_disableRAM         = [__td_disPresetProperties containsObject:kTDPerformanceRAM];
            _td_disableFPS         = [__td_disPresetProperties containsObject:kTDPerformanceFPS];
            _td_disableSimulator   = [__td_disPresetProperties containsObject:kTDPerformanceSIM];
            
            _td_disableAppVersion  = [__td_disPresetProperties containsObject:kTDPresentAppVersion];
            _td_disableOsVersion   = [__td_disPresetProperties containsObject:kTDPresentOsVersion];
            _td_disableManufacturer = [__td_disPresetProperties containsObject:kTDPresentManufacturer];
            _td_disableDeviceModel = [__td_disPresetProperties containsObject:kTDPresentDeviceModel];
            _td_disableScreenHeight = [__td_disPresetProperties containsObject:kTDPresentScreenHeight];
            _td_disableScreenWidth = [__td_disPresetProperties containsObject:kTDPresentScreenWidth];
            _td_disableCarrier = [__td_disPresetProperties containsObject:kTDPresentCarrier];
            _td_disableDeviceId = [__td_disPresetProperties containsObject:kTDPresentDeviceId];
            _td_disableSystemLanguage = [__td_disPresetProperties containsObject:kTDPresentSystemLanguage];
            _td_disableLib = [__td_disPresetProperties containsObject:kTDPresentLib];
            _td_disableLibVersion = [__td_disPresetProperties containsObject:kTDPresentLibVersion];
            _td_disableBundleId = [__td_disPresetProperties containsObject:kTDPresentBundleId];
            _td_disableOs = [__td_disPresetProperties containsObject:kTDPresentOs];
            _td_disableInstallTime = [__td_disPresetProperties containsObject:kTDPresentInstallTime];
            _td_disableDeviceType = [__td_disPresetProperties containsObject:kTDPresentDeviceType];
            //_td_disableSessionID = [__td_disPresetProperties containsObject:kTDPresentSessionID];
            //_td_disableCalibratedTime = [__td_disPresetProperties containsObject:kTDPresentCalibratedTime];
            _td_disableSessionID = YES;
            _td_disableCalibratedTime = YES;

            _td_disableNetworkType = [__td_disPresetProperties containsObject:kTDPresentNETWORKTYPE];
            _td_disableZoneOffset = [__td_disPresetProperties containsObject:kTDPresentZONEOFFSET];
            _td_disableDuration = [__td_disPresetProperties containsObject:kTDPresentDURATION];
            _td_disableBackgroundDuration = [__td_disPresetProperties containsObject:kTDPresentBACKGROUNDDURATION];
            _td_disableAppCrashedReason = [__td_disPresetProperties containsObject:kTDPresentCRASHREASON];
            _td_disableResumeFromBackground = [__td_disPresetProperties containsObject:kTDPresentRESUMEFROMBACKGROUND];
            _td_disableElementId = [__td_disPresetProperties containsObject:kTDPresentELEMENTID];
            _td_disableElementType = [__td_disPresetProperties containsObject:kTDPresentELEMENTTYPE];
            _td_disableElementContent = [__td_disPresetProperties containsObject:kTDPresentELEMENTCONTENT];
            _td_disableElementPosition = [__td_disPresetProperties containsObject:kTDPresentELEMENTPOSITION];
            _td_disableElementSelector = [__td_disPresetProperties containsObject:kTDPresentELEMENTSELECTOR];
            _td_disableScreenName = [__td_disPresetProperties containsObject:kTDPresentSCREENNAME];
            _td_disableTitle = [__td_disPresetProperties containsObject:kTDPresentTITLE];
            _td_disableUrl = [__td_disPresetProperties containsObject:kTDPresentURL];
            _td_disableReferrer = [__td_disPresetProperties containsObject:kTDPresentREFERRER];
            _td_disableOpsReceiptProperties = [__td_disPresetProperties containsObject:kTDPresentOpsReceiptProperties];
        }
    });
    return __td_disPresetProperties;
}

+ (BOOL)disableOpsReceiptProperties {
    return  _td_disableOpsReceiptProperties;
}

+ (BOOL)disableStartReason {
    return _td_disableStartReason;
}

+ (BOOL)disableDisk {
    return _td_disableDisk;
}

+ (BOOL)disableRAM {
    return _td_disableRAM;
}

+ (BOOL)disableFPS {
    return _td_disableFPS;
}

+ (BOOL)disableSimulator {
    return _td_disableSimulator;
}




+ (BOOL)disableAppVersion {
    return _td_disableAppVersion;
}

+ (BOOL)disableOsVersion {
    return _td_disableOsVersion;
}

+ (BOOL)disableManufacturer {
    return _td_disableManufacturer;
}

+ (BOOL)disableDeviceId {
    return _td_disableDeviceId;
}

+ (BOOL)disableDeviceModel {
    return _td_disableDeviceModel;
}

+ (BOOL)disableScreenHeight {
    return _td_disableScreenHeight;
}

+ (BOOL)disableScreenWidth {
    return _td_disableScreenWidth;
}

+ (BOOL)disableCarrier {
    return _td_disableCarrier;
}

+ (BOOL)disableSystemLanguage {
    return _td_disableSystemLanguage;
}

+ (BOOL)disableLib {
    return _td_disableLib;
}

+ (BOOL)disableLibVersion {
    return _td_disableLibVersion;
}

+ (BOOL)disableOs {
    return _td_disableOs;
}

+ (BOOL)disableBundleId {
    return _td_disableBundleId;
}

+ (BOOL)disableInstallTime {
    return _td_disableInstallTime;
}

+ (BOOL)disableDeviceType {
    return _td_disableDeviceType;
}

+ (BOOL)disableNetworkType {
    return _td_disableNetworkType;
}

+ (BOOL)disableZoneOffset {
    return _td_disableZoneOffset;
}

+ (BOOL)disableDuration {
    return _td_disableDuration;
}

+ (BOOL)disableBackgroundDuration {
    return _td_disableBackgroundDuration;
}

+ (BOOL)disableAppCrashedReason {
    return _td_disableAppCrashedReason;
}

+ (BOOL)disableResumeFromBackground {
    return _td_disableResumeFromBackground;
}

+ (BOOL)disableElementId {
    return _td_disableElementId;
}

+ (BOOL)disableElementType {
    return _td_disableElementType;
}

+ (BOOL)disableElementContent {
    return _td_disableElementContent;
}

+ (BOOL)disableElementPosition {
    return _td_disableElementPosition;
}

+ (BOOL)disableElementSelector {
    return _td_disableElementSelector;
}

+ (BOOL)disableScreenName {
    return _td_disableScreenName;
}

+ (BOOL)disableTitle {
    return _td_disableTitle;
}

+ (BOOL)disableUrl {
    return _td_disableUrl;
}

+ (BOOL)disableReferrer {
    return _td_disableReferrer;
}

+ (BOOL)disableSessionID {
    return _td_disableSessionID;
}

+ (BOOL)disableCalibratedTime {
    return _td_disableCalibratedTime;
}

@end
