#import "TDDeviceInfo.h"

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

#import "TDKeychainHelper.h"
#import "TDPublicConfig.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDFile.h"

#define kTDDyldPropertyNames @[@"TDPerformance"]
#define kTDGetPropertySelName @"getPresetProperties"

@interface TDDeviceInfo ()

@property (nonatomic, readwrite) BOOL isFirstOpen;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;
@property (nonatomic, strong) NSDictionary *automaticData;

@end

@implementation TDDeviceInfo

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
        
        _automaticData = [self td_collectProperties];
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
        
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
    UIDevice *device = [UIDevice currentDevice];
    [p setValue:_deviceId forKey:@"#device_id"];
    _telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = nil;
    NSString *carrierName = @"";

#ifdef __IPHONE_12_0
        if (@available(iOS 12.1, *)) {
            // 双卡双待的情况
            NSArray *carrierKeysArray = [_telephonyInfo.serviceSubscriberCellularProviders.allKeys sortedArrayUsingSelector:@selector(compare:)];
            carrier = _telephonyInfo.serviceSubscriberCellularProviders[carrierKeysArray.firstObject];
            if (!carrier.mobileNetworkCode) {
                carrier = _telephonyInfo.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
            }
        }
#endif
    
    if (!carrier) {
        carrier = [_telephonyInfo subscriberCellularProvider];
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
    CGSize size = [UIScreen mainScreen].bounds.size;
    [p addEntriesFromDictionary:@{
        @"#lib": self.libName,
        @"#lib_version": self.libVersion,
        @"#manufacturer": @"Apple",
        @"#device_model": [self td_iphoneType],
        @"#os": @"iOS",
        @"#os_version": [device systemVersion],
        @"#screen_height": @((NSInteger)size.height),
        @"#screen_width": @((NSInteger)size.width),
    }];
    
    NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
    if (preferredLanguages && preferredLanguages.length > 0) {
        p[@"#system_language"] = [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
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

- (NSString *)getIdentifier {
    NSString *anonymityId = NULL;
    
    if (NSClassFromString(@"UIDevice")) {
        anonymityId = [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    if (!anonymityId) {
        anonymityId = [[NSUUID UUID] UUIDString];
    }
    
    return anonymityId;
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
