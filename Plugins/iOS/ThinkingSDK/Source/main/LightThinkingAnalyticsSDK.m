#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDLogging.h"

@implementation LightThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self initLight:appID withServerURL:serverURL withConfig:config]) {
    }
    return self;
}

- (void)innerLogin:(NSString *)accountId {
    if ([self hasDisabled]) {
        return;
    }
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }
    TDLogInfo(@"light SDK login, SDK Name = %@, AccountId = %@", self.config.name, accountId);
    self.accountId = accountId;
}

- (void)innerLogout {
    if ([self hasDisabled]) {
        return;
    }
    TDLogInfo(@"light SDK logout.");
    self.accountId = nil;
}

- (void)innerSetIdentify:(NSString *)distinctId {
    if ([self hasDisabled]) {
        return;
    }
    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    TDLogInfo(@"light SDK set distinct ID, Distinct Id = %@", distinctId);
    
    self.identifyId = distinctId;
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType withAppId:(NSString *)appId {
    return;
}

+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType callback:(NSDictionary * _Nonnull (^)(TDAutoTrackEventType, NSDictionary * _Nonnull))callback withAppId:(NSString *)appId {
    return;
}
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary *)properties withAppId:(NSString *)appId {
    return;
}

- (void)innerFlush {
    return;
}

#pragma mark - EnableTracking

- (void)innerSetTrackStatus: (TDTrackStatus)status {
    switch (status) {
        case TDTrackStatusPause: {
            TDLogInfo(@"light instance [%@] change status to Pause", self.config.name)
            self.isEnabled = NO;
            break;
        }
        case TDTrackStatusStop: {
            TDLogInfo(@"light instance [%@] change status to Stop", self.config.name)
            self.isEnabled = NO;
            break;
        }
        case TDTrackStatusSaveOnly: {
            TDLogInfo(@"light instance [%@] change status to SaveOnly", self.config.name)
            self.isEnabled = YES;
            break;
        }
        case TDTrackStatusNormal: {
            TDLogInfo(@"light instance [%@] change status to Normal", self.config.name)
            self.isEnabled = YES;
            break;
        }
        default:
            break;
    }
}

@end
