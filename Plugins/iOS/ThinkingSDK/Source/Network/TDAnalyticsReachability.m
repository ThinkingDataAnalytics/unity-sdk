//
//  TDAnalyticsReachability.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//

#import "TDAnalyticsReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

#if __has_include(<ThinkingDataCore/TAModuleManager.h>)
#import <ThinkingDataCore/TAModuleManager.h>
#else
#import "TAModuleManager.h"
#endif
#import "TDAnalyticsRouterEventManager.h"


@interface TDAnalyticsReachability ()
#if TARGET_OS_IOS
@property (atomic, assign) SCNetworkReachabilityRef reachability;
#endif
@property (nonatomic, assign) BOOL isWifi;
@property (nonatomic, assign) BOOL isWwan;

@end

@implementation TDAnalyticsReachability

#if TARGET_OS_IOS
static void ThinkingReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    TDAnalyticsReachability *instance = (__bridge TDAnalyticsReachability *)info;
    if (instance && [instance isKindOfClass:[TDAnalyticsReachability class]]) {
        [instance reachabilityChanged:flags];
        [[TAModuleManager sharedManager] triggerEvent:TAMDidCustomEvent withCustomParam:[TDAnalyticsRouterEventManager netwokChangedEvent:[instance networkState]]];
    }
}
#endif

//MARK: - Public Methods

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TDAnalyticsReachability *reachability = nil;
    dispatch_once(&onceToken, ^{
        reachability = [[TDAnalyticsReachability alloc] init];
    });
    return reachability;
}

#if TARGET_OS_IOS

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

+ (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    if ([@"NULL" isEqualToString:networkType]) {
        return ThinkingNetworkTypeALL;
    } else if ([@"WIFI" isEqualToString:networkType]) {
        return ThinkingNetworkTypeWIFI;
    } else if ([@"2G" isEqualToString:networkType]) {
        return ThinkingNetworkType2G;
    } else if ([@"3G" isEqualToString:networkType]) {
        return ThinkingNetworkType3G;
    } else if ([@"4G" isEqualToString:networkType]) {
        return ThinkingNetworkType4G;
    }else if([@"5G"isEqualToString:networkType])
    {
        return ThinkingNetworkType5G;
    }
    return ThinkingNetworkTypeNONE;
}

//MARK: - Private Methods

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    self.isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
    self.isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
}

- (NSString *)currentRadio {
    NSString *networkType = @"NULL";
    @try {
        static CTTelephonyNetworkInfo *info = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            info = [[CTTelephonyNetworkInfo alloc] init];
        });
        NSString *currentRadio = nil;
#ifdef __IPHONE_12_0
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceCurrentRadio = [info serviceCurrentRadioAccessTechnology];
            if ([serviceCurrentRadio isKindOfClass:[NSDictionary class]] && serviceCurrentRadio.allValues.count>0) {
                currentRadio = serviceCurrentRadio.allValues[0];
            }
        }
#endif
        if (currentRadio == nil && [info.currentRadioAccessTechnology isKindOfClass:[NSString class]]) {
            currentRadio = info.currentRadioAccessTechnology;
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

#elif TARGET_OS_OSX

+ (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
    return ThinkingNetworkTypeWIFI;
}

- (void)startMonitoring {
}

- (void)stopMonitoring {
}

- (NSString *)currentRadio {
    return @"WIFI";
}

- (NSString *)networkState {
    return @"WIFI";
}

#endif

@end
