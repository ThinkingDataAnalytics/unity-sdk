//
//  TDNetworkReachability.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/15.
//

#import "TDNetworkReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "TDNotificationManager+Networking.h"

@interface TDNetworkReachability ()
@property (atomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, assign) BOOL isWifi;
@property (nonatomic, assign) BOOL isWwan;
@property (nonatomic, strong) CTTelephonyNetworkInfo *td_TelephonyNetworkInfo;

@end

@implementation TDNetworkReachability

#if TARGET_OS_IOS
static void ThinkingReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    TDNetworkReachability *instance = (__bridge TDNetworkReachability *)info;
    if (instance && [instance isKindOfClass:[TDNetworkReachability class]]) {
        [instance reachabilityChanged:flags];
        [TDNotificationManager postNetworkStatusChanged:[instance networkState]];
    }
}
#endif

//MARK: - Public Methods

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TDNetworkReachability *reachability = nil;
    dispatch_once(&onceToken, ^{
        reachability = [[TDNetworkReachability alloc] init];
    });
    return reachability;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.td_TelephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return self;
}

- (NSString *)networkState {
    if (self.isWifi) {
        return @"WIFI";
    } else if (self.isWwan) {
        return [self currentRadio];
    } else {
        return @"NULL";
    }
}

- (void)startMonitoring {
    [self stopMonitoring];

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,"thinkingdata.cn");
    self.reachability = reachability;
    
    if (self.reachability != NULL) {
        SCNetworkReachabilityFlags flags;
        BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(self.reachability, &flags);
        if (didRetrieveFlags) {
            self.isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
            self.isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
        }
        
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if (SCNetworkReachabilitySetCallback(self.reachability, ThinkingReachabilityCallback, &context)) {
            if (!SCNetworkReachabilityScheduleWithRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes)) {
                SCNetworkReachabilitySetCallback(self.reachability, NULL, NULL);
            }
        }
    }
}

- (void)stopMonitoring {
    if (!self.reachability) {
        return;
    }
    SCNetworkReachabilityUnscheduleFromRunLoop(self.reachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

//MARK: - Private Methods

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    self.isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
    self.isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
}

- (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    @try {
        NSString *currentRadio = nil;
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [self.td_TelephonyNetworkInfo serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [self.td_TelephonyNetworkInfo.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = self.td_TelephonyNetworkInfo.currentRadioAccessTechnology;
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
//        TDLogError(@"%@: %@", self, exception);
    }
    
    return networkType;
}

- (nullable NSString *)carrier {
#ifdef __IPHONE_16_0
    return nil;
#else
    CTCarrier *carrier = nil;
    NSString *carrierName = @"";
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSArray *carrierKeysArray = [self.td_TelephonyNetworkInfo.serviceSubscriberCellularProviders.allKeys sortedArrayUsingSelector:@selector(compare:)];
            carrier = self.td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.firstObject];
            if (!carrier.mobileNetworkCode) {
                carrier = self.td_TelephonyNetworkInfo.serviceSubscriberCellularProviders[carrierKeysArray.lastObject];
            }
        }
#endif
    if (!carrier) {
        carrier = [self.td_TelephonyNetworkInfo subscriberCellularProvider];
    }
    
    // System characteristics, when the SIM is not installed, the carrierName also has a value, here additionally add the judgment of whether MCC and MNC have values
    // MCC, MNC, and isoCountryCode are nil when no SIM card is installed and not within the cellular service range
    if (carrier.carrierName &&
        carrier.carrierName.length > 0 &&
        carrier.mobileNetworkCode &&
        carrier.mobileNetworkCode.length > 0) {
        carrierName = carrier.carrierName;
    }
    return carrierName;
#endif
}

@end
