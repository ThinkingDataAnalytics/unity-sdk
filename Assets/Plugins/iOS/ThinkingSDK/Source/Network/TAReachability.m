//
//  TAReachability.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/1.
//

#import "TAReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

@interface TAReachability ()
@property (atomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, assign) BOOL isWifi;
@property (nonatomic, assign) BOOL isWwan;

@end

@implementation TAReachability

/// 网络状态监听的回调方法
static void ThinkingReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    TAReachability *instance = (__bridge TAReachability *)info;
    if (instance && [instance isKindOfClass:[TAReachability class]]) {
        [instance reachabilityChanged:flags];
    }
}

//MARK: - Public Methods

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TAReachability *reachability = nil;
    dispatch_once(&onceToken, ^{
        reachability = [[TAReachability alloc] init];
    });
    return reachability;
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

@end
