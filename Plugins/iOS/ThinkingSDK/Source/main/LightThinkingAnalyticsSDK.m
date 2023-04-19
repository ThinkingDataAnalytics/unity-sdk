#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDLogging.h"

@implementation LightThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self initLight:appID withServerURL:serverURL withConfig:config]) {
    }
    
    return self;
}

- (void)login:(NSString *)accountId {
    if ([self hasDisabled])
        return;
    
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }
    
    @synchronized (self.accountId) {
        self.accountId = accountId;
    }
}

- (void)logout {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    };
}

- (void)identify:(NSString *)distinctId {
    if ([self hasDisabled])
        return;
    
    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    @synchronized (self.identifyId) {
        self.identifyId = distinctId;
    };
}

- (NSString *)getDistinctId {
    return [self.identifyId copy];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return;
}

- (void)flush {
    return;
}

#pragma mark - EnableTracking
- (void)enableTracking:(BOOL)enabled {
    TDLogDebug(@"%@light instance: enableTracking...", self);
    self.isEnabled = enabled;
}

- (void)optOutTracking {
    TDLogDebug(@"%@light instance: optOutTracking...", self);
    self.isEnabled = NO;
}

- (void)optOutTrackingAndDeleteUser {
    TDLogDebug(@"%@light instance: optOutTrackingAndDeleteUser...", self);
    self.isEnabled = NO;
}

- (void)optInTracking {
    TDLogDebug(@"%@light instance: optInTracking...", self);
    self.isEnabled = YES;
}



- (void)setTrackStatus: (TATrackStatus)status {
    switch (status) {
            
        case TATrackStatusPause: {
            TDLogDebug(@"%@light instance - switchTrackStatus: TATrackStatusStop...", self);
            self.isEnabled = NO;
            break;
        }
            
        case TATrackStatusStop: {
            TDLogDebug(@"%@light instance - switchTrackStatus: TATrackStatusStopAndClean...", self);
            self.isEnabled = NO;
            break;
        }
            
        case TATrackStatusSaveOnly: {
            TDLogDebug(@"%@light instance - switchTrackStatus: TATrackStatusPausePost...", self);
            self.trackPause = YES;
            break;
        }
            
        case TATrackStatusNormal: {
            TDLogDebug(@"%@light instance - switchTrackStatus: TATrackStatusRestartAll...", self);
            self.trackPause = NO;
            self.isEnabled = YES;
            [self flush];
            break;
        }
        default:
            break;
    }
}


@end
