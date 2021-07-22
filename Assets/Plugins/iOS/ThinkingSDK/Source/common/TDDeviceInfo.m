#import "TDDeviceInfo.h"

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/utsname.h>

#import "TDKeychainItemWrapper.h"
#import "TDPublicConfig.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDFile.h"

@interface TDDeviceInfo ()

@property (nonatomic, readwrite) BOOL isFirstOpen;
@property (nonatomic, strong) CTTelephonyNetworkInfo *telephonyInfo;

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
        _uniqueId = [deviceInfo objectForKey:@"uniqueId"];
        _deviceId = [deviceInfo objectForKey:@"deviceId"];
        _automaticData = [self collectAutomaticProperties];
        _appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    }
    return self;
}

+ (NSString *)libVersion {
    return [self sharedManager].libVersion;
}

- (void)updateAutomaticData {
    _automaticData = [self collectAutomaticProperties];
}

- (NSDictionary *)collectAutomaticProperties {
    NSMutableDictionary *p = [NSMutableDictionary dictionary];
    UIDevice *device = [UIDevice currentDevice];
    [p setValue:_deviceId forKey:@"#device_id"];
    _telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = nil;

#ifdef __IPHONE_12_1
    if (@available(iOS 12.1, *)) {
        carrier = _telephonyInfo.serviceSubscriberCellularProviders.allValues.firstObject; 
    }
#endif
    
    if (!carrier) {
        carrier = [_telephonyInfo subscriberCellularProvider];
    }

    [p setValue:carrier.carrierName forKey:@"#carrier"];
    CGSize size = [UIScreen mainScreen].bounds.size;
    [p addEntriesFromDictionary:@{
        @"#lib": self.libName,
        @"#lib_version": self.libVersion,
        @"#manufacturer": @"Apple",
        @"#device_model": [self iphoneType],
        @"#os": @"iOS",
        @"#os_version": [device systemVersion],
        @"#screen_height": @((NSInteger)size.height),
        @"#screen_width": @((NSInteger)size.width),
    }];
    
    NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
    if (preferredLanguages && preferredLanguages.length > 0) {
        p[@"#system_language"] = [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
    }
    
    return [p copy];
}
+ (NSString*)bundleId
{
     return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
//TODO
- (NSString *)iphoneType {
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

- (NSDictionary *)getDeviceUniqueId {
    NSString *defaultDistinctId = [self getIdentifier];
    NSString *deviceId;
    NSString *uniqueId;
    
    TDKeychainItemWrapper *wrapper = [[TDKeychainItemWrapper alloc] init];
    NSString *deviceIdKeychain = [wrapper readDeviceId];
    NSString *installTimesKeychain = [wrapper readInstallTimes];
    BOOL isExistFirstRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:@"thinking_isfirst"] boolValue];
    if (!isExistFirstRecord) {
        _isFirstOpen = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        _isFirstOpen = NO;
    }
    
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        [wrapper readOldKeychain];
        deviceIdKeychain = [wrapper getDeviceIdOld];
        installTimesKeychain = [wrapper getInstallTimesOld];
    }
    
    TDFile *file = [[TDFile alloc] initWithAppid:[ThinkingAnalyticsSDK sharedInstance].appid];
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
        deviceIdKeychain = [file unarchiveDeviceId];
        installTimesKeychain = [file unarchiveInstallTimes];
    }
    
    if (deviceIdKeychain.length == 0 || installTimesKeychain.length == 0) {
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

@end
