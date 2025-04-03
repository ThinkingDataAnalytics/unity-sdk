#import "TDDeviceInfo.h"
#import "TDPublicConfig.h"
#import "TDKeychainHelper.h"
#import "TDFile.h"
#import "TDKeychainHelper.h"

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif

#if __has_include(<ThinkingDataCore/TDCoreKeychainHelper.h>)
#import <ThinkingDataCore/TDCoreKeychainHelper.h>
#else
#import "TDCoreKeychainHelper.h"
#endif

#import "ThinkingAnalyticsSDKPrivate.h"


@interface TDDeviceInfo ()
@property (nonatomic, copy, readwrite) NSString *uniqueId;
@property (nonatomic, assign, readwrite) BOOL isFirstOpen;

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
        self.libVersion = [TDPublicConfig version];
    }
    return self;
}

+ (NSString *)libVersion {
    return [self sharedManager].libVersion;
}

- (NSString *)uniqueId {
    static dispatch_once_t onceToken;
    static NSString *uniqueId = nil;
    dispatch_once(&onceToken, ^{
        uniqueId = [self getDeviceUniqueId];
    });
    return uniqueId;
}


#if TARGET_OS_OSX

- (nullable NSString *)getSystemSerialNumber {
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

- (NSString *)getDeviceUniqueId {
    NSString *keyExistFirstRecord = @"thinking_isfirst";
    BOOL isExistFirstRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:keyExistFirstRecord] boolValue];
    if (!isExistFirstRecord) {
        self.isFirstOpen = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyExistFirstRecord];
    } else {
        self.isFirstOpen = NO;
    }
    
    NSString *keyDefaultDistinctId = @"thinking_data_default_distinct_id";
    NSString *defaultDistinctId = [[NSUserDefaults standardUserDefaults] stringForKey:keyDefaultDistinctId];
    if (!defaultDistinctId) {
        defaultDistinctId = [TDCoreDeviceInfo deviceId];
        [[NSUserDefaults standardUserDefaults] setObject:defaultDistinctId forKey:keyDefaultDistinctId];
    }
    
    return defaultDistinctId;
}

#endif

#if TARGET_OS_IOS

- (NSString *)getDeviceUniqueId {
    NSString *uniqueId = nil;
    @synchronized (self) {
        NSString *deviceId = [TDCoreDeviceInfo deviceId];
        NSString *installTimes = [TDKeychainHelper readInstallTimes];
        BOOL isExistFirstRecord = [[[NSUserDefaults standardUserDefaults] objectForKey:@"thinking_isfirst"] boolValue];
        if (!isExistFirstRecord) {
            self.isFirstOpen = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"thinking_isfirst"];
        } else {
            self.isFirstOpen = NO;
        }
        
        TDFile *file = [[TDFile alloc] initWithAppid:[ThinkingAnalyticsSDK defaultInstance].config.appid];
        if (deviceId.length == 0) {
            deviceId = [file unarchiveDeviceId];
            if (deviceId.length > 0) {
                [TDCoreKeychainHelper saveDeviceId:deviceId];
            }
        }
        if (installTimes.length == 0) {
            installTimes = [file unarchiveInstallTimes];
            if (installTimes.length > 0) {
                [TDKeychainHelper saveInstallTimes:installTimes];
            }
        }
        if (installTimes.length == 0) {
            installTimes = @"1";
            [file archiveInstallTimes:installTimes];
            [TDKeychainHelper saveInstallTimes:installTimes];
        } else {
            if (!isExistFirstRecord) {
                int setup_int = [installTimes intValue];
                setup_int++;
                installTimes = [NSString stringWithFormat:@"%d", setup_int];
                [file archiveInstallTimes:installTimes];
                [TDKeychainHelper saveInstallTimes:installTimes];
            }
        }
        
        if ([installTimes isEqualToString:@"1"]) {
            uniqueId = deviceId;
        } else {
            uniqueId = [NSString stringWithFormat:@"%@_%@",deviceId, installTimes];
        }
    }
    return uniqueId;
}

#endif

@end
