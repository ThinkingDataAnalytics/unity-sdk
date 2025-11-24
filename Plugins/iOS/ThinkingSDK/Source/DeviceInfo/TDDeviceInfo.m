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

#if __has_include(<ThinkingDataCore/TDUserDefaults.h>)
#import <ThinkingDataCore/TDUserDefaults.h>
#else
#import "TDUserDefaults.h"
#endif

#import "ThinkingAnalyticsSDKPrivate.h"

static NSString * kInstallEventFlagSeparator = @"&td&";
static NSString * kUserDefaultFirstOpenFlag = @"thinking_isfirst";
static NSString * kUserDefaultInstallTimes = @"thinking_data_install_times";
static NSString * kUserDefaultTrackInstallSuccess = @"thinking_data_install_track_success";

@interface TDDeviceInfo ()
@property (atomic, copy) NSString *installTimes;
@property (atomic, copy) NSString *deviceId;
@property (nonatomic, copy, readwrite) NSString *uniqueId;
@property (nonatomic, assign, readwrite) BOOL isFirstOpen;
@property (atomic, assign, readwrite) BOOL isInstallTrackSuccess;

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
        [self configInstallTimes];
        self.deviceId = [TDCoreDeviceInfo deviceId];
        
        if (self.isFirstOpen) {
            NSString *installEventFlag = [NSString stringWithFormat:@"%@%@0", [TDCoreDeviceInfo appVersion], kInstallEventFlagSeparator];
            [[TDUserDefaults standardUserDefaults] setString:installEventFlag forKey:kUserDefaultTrackInstallSuccess];
        }
        NSString *installEventFlag = [[TDUserDefaults standardUserDefaults] objectForKey:kUserDefaultTrackInstallSuccess];
        if ([installEventFlag isKindOfClass:NSString.class]) {
            NSArray<NSString *> *values = [installEventFlag componentsSeparatedByString:kInstallEventFlagSeparator];
            if (values.count == 2) {
                NSString *appVersion = values.firstObject;
                BOOL isInstallTrackSuccess = [values.lastObject boolValue];
                if ([[TDCoreDeviceInfo appVersion] isEqualToString:appVersion]) {
                    self.isInstallTrackSuccess = isInstallTrackSuccess;
                } else {
                    // Event 'td_app_install' is not reported when the app version is upgraded. Regardless of whether installation events have been reported
                    self.isInstallTrackSuccess = YES;
                }
            } else {
                // default is YES.
                self.isInstallTrackSuccess = YES;
            }
        } else {
            // default is YES.
            self.isInstallTrackSuccess = YES;
        }
    }
    return self;
}

+ (NSString *)libVersion {
    return [self sharedManager].libVersion;
}

- (NSString *)uniqueId {
    return [self getDeviceUniqueId];
}

- (void)setAppInstallFlag {
    self.isInstallTrackSuccess = YES;
    NSString *installEventFlag = [NSString stringWithFormat:@"%@%@1", [TDCoreDeviceInfo appVersion], kInstallEventFlagSeparator];
    [[TDUserDefaults standardUserDefaults] setString:installEventFlag forKey:kUserDefaultTrackInstallSuccess];
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
    NSString *keyDefaultDistinctId = @"thinking_data_default_distinct_id";
    NSString *defaultDistinctId = [[TDUserDefaults standardUserDefaults] stringForKey:keyDefaultDistinctId];
    if (!defaultDistinctId) {
        defaultDistinctId = [TDCoreDeviceInfo deviceId];
        [[TDUserDefaults standardUserDefaults] setObject:defaultDistinctId forKey:keyDefaultDistinctId];
    }
    
    return defaultDistinctId;
}

- (void)configInstallTimes {
    NSString *keyExistFirstRecord = kUserDefaultFirstOpenFlag;
    BOOL isExistFirstRecord = [[[TDUserDefaults standardUserDefaults] objectForKey:keyExistFirstRecord] boolValue];
    if (!isExistFirstRecord) {
        self.isFirstOpen = YES;
        [[TDUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFirstOpenFlag];
    } else {
        self.isFirstOpen = NO;
    }
}

#endif

#if TARGET_OS_IOS

- (NSString *)getDeviceUniqueId {
    NSString *uniqueId = nil;
    if ([self.installTimes isEqualToString:@"1"]) {
        uniqueId = self.deviceId;
    } else {
        uniqueId = [NSString stringWithFormat:@"%@_%@", self.deviceId, self.installTimes];
    }
    return uniqueId;
}

- (void)configInstallTimes {
    @synchronized (self) {
        BOOL isExistFirstRecord = [[[TDUserDefaults standardUserDefaults] objectForKey:kUserDefaultFirstOpenFlag] boolValue];
        if (!isExistFirstRecord) {
            self.isFirstOpen = YES;
            [[TDUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultFirstOpenFlag];
        } else {
            self.isFirstOpen = NO;
        }
        
        NSString *installTimes = [TDKeychainHelper readInstallTimes];
        if (installTimes == nil || [installTimes isKindOfClass:NSString.class] == NO || installTimes.length == 0) {
            installTimes = [[TDUserDefaults standardUserDefaults] stringForKey:kUserDefaultInstallTimes];
        }
        if (!isExistFirstRecord) {
            int setup_int = [installTimes intValue];
            setup_int += 1;
            installTimes = [NSString stringWithFormat:@"%d", setup_int];
        }
        if (installTimes == nil || installTimes.length == 0) {
            installTimes = @"1";
        }
        [[TDUserDefaults standardUserDefaults] setString:installTimes forKey:kUserDefaultInstallTimes];
        [TDKeychainHelper saveInstallTimes:installTimes];

        self.installTimes = installTimes;
    }
}

#endif

@end
