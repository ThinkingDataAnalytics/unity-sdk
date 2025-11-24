//
//  TDCoreDeviceInfo.m
//  Pods
//
//  Created by 杨雄 on 2024/4/23.
//

#import "TDCoreDeviceInfo.h"
#import <sys/sysctl.h>
#include <mach/mach.h>
#import "TDCoreKeychainHelper.h"
#import <sys/utsname.h>

#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#endif

#if TARGET_OS_IOS || TARGET_OS_VISION
#import <UIKit/UIKit.h>
#endif

#if TARGET_OS_IOS
#import "TDNetworkReachability.h"
#import "TDCoreFPSMonitor.h"
#endif
#import "TDUserDefaults.h"

@implementation TDCoreDeviceInfo

#if TARGET_OS_IOS
+ (void)load {
    [[TDNetworkReachability shareInstance] startMonitoring];
}
#endif

+ (NSTimeInterval)bootTime {
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

+ (NSString *)manufacturer {
    return @"Apple";
}

+ (nullable NSString *)systemLanguage {
    NSString *preferredLanguages = [[NSLocale preferredLanguages] firstObject];
    if (preferredLanguages && preferredLanguages.length > 0) {
        return [[preferredLanguages componentsSeparatedByString:@"-"] firstObject];;
    }
    return nil;
}

+ (NSString *)bundleId {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

#if (TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_VISION || TARGET_OS_TV)
static NSString *g_device_id;
+ (NSString *)deviceId {
    @synchronized (self) {
        if (g_device_id == nil) {
            NSString *keyDeviceId = @"thinking_data_device_id";
            g_device_id = [TDCoreKeychainHelper readDeviceId];
            if (!([g_device_id isKindOfClass:NSString.class] && g_device_id.length > 0)) {
                g_device_id = [[TDUserDefaults standardUserDefaults] stringForKey:keyDeviceId];
            }
            if (!g_device_id) {
                g_device_id = [self defaultIdentifier];
            }
            [[TDUserDefaults standardUserDefaults] setObject:g_device_id forKey:keyDeviceId];
            [TDCoreKeychainHelper saveDeviceId:g_device_id];
        }
    }
    return g_device_id;
}

#define kDeviceClass @"XY2HU4AX3JI2JJW5MDhjm6wea2x6ymvm28ylmiyh7jkc8axy9mw3em8w"
#define kCurrentDevice @"0a223h444j555cm666uw77722rh985jrj323ae44y5xn5ll5tm5mD5wm6e8y9m0vm32y46i7a89x0yl32c44ml4ye5a3a5"
#define kIdfv @"hj23kik4343j545dk656ke43434hhn534536jj7676tx323423yyx547657iy7678yxf7654hhl32342im3424ww4235w546ew64645w76ll57rx67yF434hj323ao343aa546rk76l323Vx32y32y32x32e3m43w656m76nxy657k657lmd65y657yx5o323aa34kk45rk76k76lm87"
#define kUUIDStr @"323J342J342K342U657K675A87A87U879H0943AX908IJ214KWD54WW87SX98XY3425At769k93l2l548m7r32xyx76769im3234ww6576n8ax89g98k9l97m1w31242"
+ (NSString *)defaultIdentifier {
    NSString *anonymityId = NULL;
    Class deviceCls = NSClassFromString([self dealStringWithRegExp:kDeviceClass]);
    if (deviceCls) {
        SEL currentDve = NSSelectorFromString([self dealStringWithRegExp:kCurrentDevice]);
        SEL idfvor = NSSelectorFromString([self dealStringWithRegExp:kIdfv]);
        SEL uuidStr = NSSelectorFromString([self dealStringWithRegExp:kUUIDStr]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
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
#pragma clang diagnostic pop
    }
    if (!anonymityId) {
        anonymityId = [[NSUUID UUID] UUIDString];
    }
    return anonymityId;
}

#elif TARGET_OS_OSX

+ (NSString *)deviceId {
    NSString *keyDeviceId = @"thinking_data_device_id";
    NSString *deviceId = [[TDUserDefaults standardUserDefaults] stringForKey:keyDeviceId];
    if (!deviceId) {
        deviceId = [self getSystemSerialNumber];
        if (deviceId == nil) {
            deviceId = [[NSUUID UUID] UUIDString];
        }
        [[TDUserDefaults standardUserDefaults] setObject:deviceId forKey:keyDeviceId];
    }
    return deviceId;
}

+ (nullable NSString *)getSystemSerialNumber {
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
        if (serialNumberAsCFString) {
            NSString *serialNumber = (__bridge_transfer NSString *)serialNumberAsCFString;
            return serialNumber;
        }
    }
    return nil;
}

#endif

+ (NSString *)dealStringWithRegExp:(NSString *)string {
    NSRegularExpression *regExp = [[NSRegularExpression alloc]initWithPattern:@"[0-9AXYHJKLMW]" options:NSRegularExpressionCaseInsensitive error:nil];
    return [regExp stringByReplacingMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length) withTemplate:@""];
}

+ (NSDate *)installTime {
    NSURL *urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSError *error = nil;
    NSDate *installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:urlToDocumentsFolder.path error:&error] objectForKey:NSFileCreationDate];
    if (!error) {
        return installDate;
    }
    return [NSDate date];
}

+ (NSString *)ram {
    NSUInteger ramUnitGB = 1024 * 1024 * 1024;
    NSString *ram = [NSString stringWithFormat:@"%.1f/%.1f", [self td_pm_func_getFreeMemory]*1.0/ramUnitGB, [self td_pm_func_getRamSize]*1.0/ramUnitGB];
    return ram;
}

+ (NSString *)disk {
    NSUInteger diskUnitGB = 1000 * 1000 * 1000;
    NSString *disk = [NSString stringWithFormat:@"%.1f/%.1f", [self td_get_disk_free_size]*1.0/diskUnitGB, [self td_get_storage_size]*1.0/diskUnitGB];
    return disk;
}

+ (int64_t)td_pm_func_getFreeMemory {
    size_t length = 0;
    int mib[6] = {0};
    
    int pagesize = 0;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0){
        return -1;
    }
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS){
        return -1;
    }
    
    int64_t freeMem = vmstat.free_count * pagesize;
    int64_t inactiveMem = vmstat.inactive_count * pagesize;
    return freeMem + inactiveMem;
}

+ (int64_t)td_pm_func_getRamSize{
    int mib[2];
    size_t length = 0;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MEMSIZE;
    long ram;
    length = sizeof(ram);
    if (sysctl(mib, 2, &ram, &length, NULL, 0) < 0) {
        return -1;
    }
    return ram;
}

+ (NSDictionary *)td_pm_getFileAttributeDic {
    NSError *error;
    NSDictionary *directory = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error) {
        return nil;
    }
    return directory;
}

+ (long long)td_get_disk_free_size {
    NSDictionary<NSFileAttributeKey, id> *directory = [self td_pm_getFileAttributeDic];
    if (directory) {
        return [[directory objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return -1;
}

+ (long long)td_get_storage_size {
    NSDictionary<NSFileAttributeKey, id> *directory = [self td_pm_getFileAttributeDic];
    return directory ? ((NSNumber *)[directory objectForKey:NSFileSystemSize]).unsignedLongLongValue:-1;
}

+ (NSString *)appVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

+ (BOOL)isSimulator {
    BOOL result = NO;
#if TARGET_IPHONE_SIMULATOR
    result = YES;
#elif TARGET_OS_SIMULATOR
    result = YES;
#else
    result = NO;
#endif
    return result;
}

#if TARGET_OS_IOS

+ (NSNumber *)fps {
    static TDCoreFPSMonitor *fpsMonitor = nil;
    if (!fpsMonitor) {
        fpsMonitor = [[TDCoreFPSMonitor alloc] init];
        [fpsMonitor setEnable:YES];
    }
    return [fpsMonitor getPFS];
}

+ (NSNumber *)screenWidth {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return @((NSInteger)size.width);
}

+ (NSNumber *)screenHeight {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return @((NSInteger)size.height);
}

+ (NSString *)networkType {
    return [[TDNetworkReachability shareInstance] networkState];
}

+ (nullable NSString *)carrier {
    return [[TDNetworkReachability shareInstance] carrier];
}
#endif

/* ==========================================================================================================
    Warning: The following code cannot be modified, otherwise it will result in inaccurate data analysis!!!
 ============================================================================================================
 */
+ (NSString *)deviceModel {
#if (TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_VISION || TARGET_OS_TV)
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
#elif TARGET_OS_OSX
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return platform;
#endif
}

+ (NSString *)os {
#if TARGET_OS_IOS
    return @"iOS";
#elif TARGET_OS_WATCH
    return [WKInterfaceDevice currentDevice].systemName;
#elif TARGET_OS_TV
    return @"tvOS";
#elif TARGET_OS_VISION
    return [UIDevice currentDevice].systemName;
#elif TARGET_OS_OSX
    return @"OSX";
#endif
}

+ (NSString *)osVersion {
#if TARGET_OS_IOS || TARGET_OS_VISION || TARGET_OS_TV
    return [[UIDevice currentDevice] systemVersion];
#elif TARGET_OS_WATCH
    return [WKInterfaceDevice currentDevice].systemVersion;
#elif TARGET_OS_OSX
    NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *versionString = [sv objectForKey:@"ProductVersion"];
    return versionString;
#endif
    return @"";
}

+ (NSString *)deviceType {
#if TARGET_OS_IOS
    NSString *typeName = @"unknown";
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPad: {
            typeName = @"iPad";
        } break;
        case UIUserInterfaceIdiomPhone: {
            typeName = @"iPhone";
        } break;
        case UIUserInterfaceIdiomTV: {
            typeName = @"TV";
        } break;
        case UIUserInterfaceIdiomCarPlay: {
            typeName = @"CarPlay";
        } break;
#ifdef __IPHONE_14_0
        case UIUserInterfaceIdiomMac: {
            typeName = @"Mac";
        } break;
#endif
#ifdef __IPHONE_17_0
        case UIUserInterfaceIdiomVision: {
            typeName = @"Vision";
        } break;
#endif
        default:
            break;
    }
    return typeName;
#elif TARGET_OS_OSX
    return @"Mac";
#elif TARGET_OS_WATCH
    return @"AppleWatch";
#elif TARGET_OS_VISION
    return @"VisionPro";
#elif TARGET_OS_TV
    return @"AppleTV";
#endif
    return @"";
}

@end
