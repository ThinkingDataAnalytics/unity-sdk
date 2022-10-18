#import "TDDeviceInfo.h"

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

#import "TDKeychainHelper.h"
#import "TDPublicConfig.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDFile.h"
#import "TDPresetProperties+TDDisProperties.h"

#define kTDDyldPropertyNames @[@"TDPerformance"]
#define kTDGetPropertySelName @"getPresetProperties"

#define kDeviceClass @"XY2HU4AX3JI2JJW5MDhjm6wea2x6ymvm28ylmiyh7jkc8axy9mw3em8w"
#define kCurrentDevice @"0a223h444j555cm666uw77722rh985jrj323ae44y5xn5ll5tm5mD5wm6e8y9m0vm32y46i7a89x0yl32c44ml4ye5a3a5"
#define kIdfv @"hj23kik4343j545dk656ke43434hhn534536jj7676tx323423yyx547657iy7678yxf7654hhl32342im3424ww4235w546ew64645w76ll57rx67yF434hj323ao343aa546rk76l323Vx32y32y32x32e3m43w656m76nxy657k657lmd65y657yx5o323aa34kk45rk76k76lm87"
#define kUUIDStr @"323J342J342K342U657K675A87A87U879H0943AX908IJ214KWD54WW87SX98XY3425At769k93l2l548m7r32xyx76769im3234ww6576n8ax89g98k9l97m1w31242"


static CTTelephonyNetworkInfo *__td_TelephonyNetworkInfo;


@interface TDDeviceInfo ()

@property (nonatomic, readwrite) BOOL isFirstOpen;
@property (nonatomic, strong) NSDictionary *automaticData;

@end

@implementation TDDeviceInfo

+ (void)load {
    __td_TelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
}


+ (TDDeviceInfo *)sharedManager {
    static dispatch_once_t onceToken;
    static TDDeviceInfo *manager;
    dispatch_once(&onceToken, ^{
        manager = [[TDDeviceInfo alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.libName = @"iOS";
        self.libVersion = TDPublicConfig.version;
        
        NSDictionary *deviceInfo = [self getDeviceUniqueId];
        _uniqueId = [deviceInfo objectForKey:@"uniqueId"];// 默认访客ID
        _deviceId = [deviceInfo objectForKey:@"deviceId"];// 默认设备id
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        
        _automaticData = [self td_collectProperties];
    }
    return self;
}

+ (NSString *)libVersion {
    return [self sharedManager].libVersion;
}

- (void)td_updateData {
    _automaticData = [self td_collectProperties];
}

-(NSDictionary *)getAutomaticData {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:_automaticData];
    [dic addEntriesFromDictionary:[TDDeviceInfo getAPMParams]];
    _automaticData = dic;
    return _automaticData;
}

- (NSDictionary *)td_collectProperties {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    
    if (![TDPresetProperties disableDeviceId]) {
        [p setValue:_deviceId forKey:@"#device_id"];
    }
    
    if (![TDPresetProperties disableCarrier]) {
        CTCarrier *carrier = nil;
        NSString *carrierName = @"";
    #ifdef __IPHONE_12_0
            if (@available(iOS 12.1, *)) {
                // 双卡双待的情况
                NSArray *carrierKeysArray = [__td_TelephonyNetworkInfo.serviceSubscriberCellularProviders.allKeys sortedArrayUsingSelector:@selector(compare:)];
                carrier = __td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.firstObject];
                if (!carrier.mobileNetworkCode) {
                    carrier = __td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
                }
            }
    #endif
        
        if (!carrier) {
            carrier = [__td_TelephonyNetworkInfo subscriberCellularProvider];
        }
        
        // 系统特性，在SIM没有安装的情况下，carrierName也存在有值的情况，这里额外添加MCC和MNC是否有值的判断
        // MCC、MNC、isoCountryCode在没有安装SIM卡、没在蜂窝服务范围内时候为nil
        if (carrier.carrierName &&
            carrier.carrierName.length > 0 &&
            carrier.mobileNetworkCode &&
            carrier.mobileNetworkCode.length > 0) {
            carrierName = carrier.carrierName;
        }
        [p setValue:carrierName forKey:@"#carrier"];
    }
    
    if (![TDPresetProperties disableLib]) {
        [p setValue:self.libName forKey:@"#lib"];
    }
    if (![TDPresetProperties disableLibVersion]) {
        [p setValue:self.libVersion forKey:@"#lib_version"];
    }
    if (![TDPresetProperties disableManufacturer]) {
        [p setValue:@"Apple" forKey:@"#manufacturer"];
    }
    if (![TDPresetProperties disableDeviceModel]) {
        [p setValue:[self td_iphoneType] forKey:@"#device_model"];
    }
    if (![TDPresetProperties disableOs]) {
        [p setValue:@"iOS" forKey:@"#os"];
    }
    if (![TDPresetProperties disableOsVersion]) {
        UIDevice *device = [UIDevice currentDevice];
        [p setValue:[device systemVersion] forKey:@"#os_version"];
    }
    if (![TDPresetProperties disableScreenWidth]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.width) forKey:@"#screen_width"];
    }
    if (![TDPresetProperties disableScreenWidth]) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [p setValue:@((NSInteger)size.height) forKey:@"#screen_height"];
    }
    if (![TDPresetProperties disableSystemLanguage]) {
        NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
        if (preferredLanguages && preferredLanguages.length > 0) {
            p[@"#system_language"] = [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
        }
    }
    // 添加性能指标
    [p addEntriesFromDictionary:[TDDeviceInfo getAPMParams]];
    
    return [p copy];
}

+ (NSString*)bundleId
{
     return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)td_iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}


/// 获取设备id和默认的访客ID
- (NSDictionary *)getDeviceUniqueId {
    // 获取IDFV
    NSString *defaultDistinctId = [self getIdentifier];
    // 设备ID
    NSString *deviceId;
    // 默认访客ID
    NSString *uniqueId;
    
    TDKeychainHelper *wrapper = [[TDKeychainHelper alloc] init];
    
    // 获取keychain中的设备ID和安装次数
    NSString *deviceIdKeychain = [wrapper readDeviceId];
    NSString *installTimesKeychain = [wrapper readInstallTimes];
    
    // 获取安装标识
    BOOL isExistFirstRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:@"thinking_isfirst"] boolValue];
    if (!isExistFirstRecord) {
        _isFirstOpen = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        _isFirstOpen = NO;
    }
    
    // keychain中没有，获取老版本数据
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        [wrapper readOldKeychain];
        deviceIdKeychain = [wrapper getDeviceIdOld];
        installTimesKeychain = [wrapper getInstallTimesOld];
    }
    
    // 检查是否持久化过该TA实例的设备ID、安装次数
    TDFile *file = [[TDFile alloc] initWithAppid:[ThinkingAnalyticsSDK sharedInstance].appid];
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        deviceIdKeychain = [file unarchiveDeviceId];
        installTimesKeychain = [file unarchiveInstallTimes];
    }
    
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        // 新设备、新用户
        deviceId = defaultDistinctId;
        installTimesKeychain = @"1";
    } else {
        if (!isExistFirstRecord) {
            int setup_int = [installTimesKeychain intValue];
            setup_int++;
            
            installTimesKeychain = [NSString stringWithFormat:@"%d",setup_int];
        }
        
        deviceId = deviceIdKeychain;
    }
    
    if ([installTimesKeychain isEqualToString:@"1"]) {
        uniqueId = deviceId;
    } else {
        uniqueId = [NSString stringWithFormat:@"%@_%@",deviceId,installTimesKeychain];
    }
    
    // keychain更新设备ID、安装次数
    // file存储设备ID、安装次数
    // uniqueId是访客ID，字符串中包含了安装次数，
    [wrapper saveDeviceId:deviceId];
    [wrapper saveInstallTimes:installTimesKeychain];
    [file archiveDeviceId:deviceId];
    [file archiveInstallTimes:installTimesKeychain];
    return @{@"uniqueId":uniqueId, @"deviceId":deviceId};
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (NSString *)getIdentifier {
    NSString *anonymityId = NULL;
    
    Class deviceCls = NSClassFromString([self dealStringWithRegExp:kDeviceClass]);
    if (deviceCls) {
        SEL currentDve = NSSelectorFromString([self dealStringWithRegExp:kCurrentDevice]);
        SEL idfvor = NSSelectorFromString([self dealStringWithRegExp:kIdfv]);
        SEL uuidStr = NSSelectorFromString([self dealStringWithRegExp:kUUIDStr]);
        
        if ([deviceCls respondsToSelector:currentDve]) {
            id cls1 = [deviceCls performSelector:currentDve];
            if (cls1 && [cls1 respondsToSelector:idfvor]) {
                id cls2 = [cls1 performSelector:idfvor];
                if (cls2 && [cls2 respondsToSelector:uuidStr]) {
                    id tempAnonymityId = [cls2 performSelector:uuidStr];
                    if ([tempAnonymityId isKindOfClass:[NSString class]]) {
                        anonymityId = tempAnonymityId;
                    }
                }
            }
        }
    }
    
    if (!anonymityId) {
        anonymityId = [[NSUUID UUID] UUIDString];
    }
    
    return anonymityId;
}

#pragma clang diagnostic pop


- (NSString *)dealStringWithRegExp:(NSString *)string {
    NSRegularExpression *regExp = [[NSRegularExpression alloc]initWithPattern:@"[0-9AXYHJKLMW]"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    return [regExp stringByReplacingMatchesInString:string
                                                     options:NSMatchingReportProgress
                                                       range:NSMakeRange(0, string.length)
                                                withTemplate:@""];
}



+ (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    
    if (!__td_TelephonyNetworkInfo) {
        return networkType;
    }
    
    @try {
        NSString *currentRadio = nil;
        
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [__td_TelephonyNetworkInfo serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [__td_TelephonyNetworkInfo.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = __td_TelephonyNetworkInfo.currentRadioAccessTechnology;
        }
        
        if ([currentRadio isEqualToString:CTRadioAccessTechnologyLTE]) {
            networkType = @"4G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyeHRPD] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyHSDPA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            networkType = @"3G";
        } else if ([currentRadio isEqualToString:CTRadioAccessTechnologyEdge] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyGPRS]) {
            networkType = @"2G";
        }
#ifdef __IPHONE_14_1
        else if (@available(iOS 14.1, *)) {
            if ([currentRadio isKindOfClass:[NSString class]]) {
                if([currentRadio isEqualToString:CTRadioAccessTechnologyNRNSA] ||
                   [currentRadio isEqualToString:CTRadioAccessTechnologyNR]) {
                    networkType = @"5G";
                }
            }
        }
#endif
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
    }
    
    return networkType;
}

+ (NSDate *)td_getInstallTime {
    
    NSURL* urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    __autoreleasing NSError *error;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path error:&error] objectForKey:NSFileCreationDate];
    if (!error) {
        return installDate;
    }
    return [NSDate date];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

+ (NSDictionary *)getAPMParams {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    for (NSString *clsName in kTDDyldPropertyNames) {
        Class cls = NSClassFromString(clsName);
        SEL sel = NSSelectorFromString(kTDGetPropertySelName);
        if (cls && sel && [cls respondsToSelector:sel]) {
            NSDictionary *result = [cls performSelector:sel];
//            NSDictionary *result = [NSObject performSelector:sel onTarget:cls withArguments:@[]];
            if ([result isKindOfClass:[NSDictionary class]] && result.allKeys.count > 0) {
                [p addEntriesFromDictionary:result];
            }
      
        }
    }
    return p;
}

#pragma clang diagnostic pop

@end
