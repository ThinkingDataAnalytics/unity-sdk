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

- (void)setSuperProperties:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    if (properties == nil) {
        return;
    }
    properties = [properties copy];
    
    if (![self checkEventProperties:properties withEventType:nil haveAutoTrackEvents:NO]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    @synchronized (self.superProperty) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperty];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.superProperty = [NSDictionary dictionaryWithDictionary:tmp];
    }
}

- (void)unsetSuperProperty:(NSString *)propertyKey {
    if ([self hasDisabled])
        return;
    
    if (![propertyKey isKindOfClass:[NSString class]] || propertyKey.length == 0)
        return;
    
    @synchronized (self.superProperty) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperty];
        tmp[propertyKey] = nil;
        self.superProperty = [NSDictionary dictionaryWithDictionary:tmp];
    }
}

- (void)clearSuperProperties {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.superProperty) {
        self.superProperty = @{};
    }
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperty copy];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return;
}

- (void)flush {
    return;
}

@end
