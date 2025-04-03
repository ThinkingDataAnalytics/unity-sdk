#import "TDConfig.h"

#import "TDAnalyticsNetwork.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDSecurityPolicy.h"
#import "TDFile.h"
#import "TDConfigPrivate.h"

#if __has_include(<ThinkingDataCore/TDCalibratedTime.h>)
#import <ThinkingDataCore/TDCalibratedTime.h>
#else
#import "TDCalibratedTime.h"
#endif
#if __has_include(<ThinkingDataCore/NSString+TDCore.h>)
#import <ThinkingDataCore/NSString+TDCore.h>
#else
#import "NSString+TDCore.h"
#endif

#define TDSDKSETTINGS_PLIST_SETTING_IMPL(TYPE, PLIST_KEY, GETTER, SETTER, DEFAULT_VALUE, ENABLE_CACHE) \
static TYPE *g_##PLIST_KEY = nil; \
+ (TYPE *)GETTER \
{ \
  if (!g_##PLIST_KEY && ENABLE_CACHE) { \
    g_##PLIST_KEY = [[[NSUserDefaults standardUserDefaults] objectForKey:@#PLIST_KEY] copy]; \
  } \
  if (!g_##PLIST_KEY) { \
    g_##PLIST_KEY = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@#PLIST_KEY] copy] ?: DEFAULT_VALUE; \
  } \
  return g_##PLIST_KEY; \
} \
+ (void)SETTER:(TYPE *)value { \
  g_##PLIST_KEY = [value copy]; \
  if (ENABLE_CACHE) { \
    if (value) { \
      [[NSUserDefaults standardUserDefaults] setObject:value forKey:@#PLIST_KEY]; \
    } else { \
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@#PLIST_KEY]; \
    } \
  } \
}


#define kTAConfigInfo @"TAConfigInfo"

static NSDictionary *configInfo;

@interface TDConfig ()
@property (nonatomic, assign) ThinkingNetworkType innerNetworkType;

@end

@implementation TDConfig

TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKMaxCacheSize, _maxNumEventsNumber, _setMaxNumEventsNumber, @10000, NO);
TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKExpirationDays, _expirationDaysNumber, _setExpirationDaysNumber, @10, NO);

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reportingNetworkType = TDReportingNetworkTypeALL;
        self.mode = TDModeNormal;
        
        _trackRelaunchedInBackgroundEvents = NO;
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G  | ThinkingNetworkType4G | ThinkingNetworkType2G | ThinkingNetworkType5G;
        _securityPolicy = [TDSecurityPolicy defaultPolicy];
        _defaultTimeZone = [NSTimeZone localTimeZone];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (!configInfo) {
            configInfo = (NSDictionary *)[[[NSBundle mainBundle] infoDictionary] objectForKey: kTAConfigInfo];
        }
        
        if (configInfo && [configInfo.allKeys containsObject:@"maxNumEvents"]) {
            [TDConfig setMaxNumEvents:[configInfo[@"maxNumEvents"] integerValue]];
        }
        if (configInfo && [configInfo.allKeys containsObject:@"expirationDays"]) {
            [TDConfig setExpirationDays:[configInfo[@"expirationDays"] integerValue]];
        }
#pragma clang diagnostic pop

    }
    return self;
}

- (instancetype)initWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl
{
    self = [self init];
    if (self) {
        _appid = appId;
        _serverUrl = serverUrl;
    }
    return self;
}

- (void)enableEncryptWithVersion:(NSUInteger)version publicKey:(NSString *)publicKey {
#if TARGET_OS_IOS
    if ([publicKey isKindOfClass:NSString.class] && publicKey.length > 0) {
        self.innerEnableEncrypt = YES;
        self.innerSecretKey = [[TDSecretKey alloc] initWithVersion:version publicKey:publicKey];
    } else {
        self.innerEnableEncrypt = NO;
    }
#endif
}

- (void)enableDNSServcie:(NSArray<TDDNSService> *)services {
    // check DNS service list
    if (!services || services.count <= 0) {
        TDLogDebug(@"Enable DNS service error: Service is empty");
        return;
    }
    NSArray<TDDNSService> *dNSServices = @[TDDNSServiceCloudFlare, TDDNSServiceCloudALi, TDDNSServiceCloudGoogle];
    
    NSMutableArray *filterServices = [NSMutableArray array];
    for (TDDNSService obj in services) {
        if ([obj isKindOfClass:NSString.class] && [dNSServices containsObject:obj]) {
            [filterServices addObject:obj];
        }
    }
    if (filterServices.count > 0) {
        TDLogDebug(@"Enable DNS service. Server url list is: %@", filterServices);
        self.dnsServices = filterServices;
        [TDAnalyticsNetwork enableDNSServcie:filterServices];
    } else {
        TDLogDebug(@"Enable DNS service error: Service url authentication failed");
    }
}

- (void)setName:(NSString *)name {
    _name = name.td_trim;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    TDConfig *config = [[[self class] allocWithZone:zone] init];
    config.trackRelaunchedInBackgroundEvents = self.trackRelaunchedInBackgroundEvents;
    config.innerNetworkType = self.innerNetworkType;
    config.launchOptions = [self.launchOptions copyWithZone:zone];
    config.mode = self.mode;
    config.reportingNetworkType = self.reportingNetworkType;
    config.securityPolicy = [self.securityPolicy copyWithZone:zone];
    config.defaultTimeZone = [self.defaultTimeZone copyWithZone:zone];
    config.name = [self.name copy];
    config.appGroupName = [self.appGroupName copy];
    config.serverUrl = [self.serverUrl copy];
    config.enableAutoPush = self.enableAutoPush;
    config.dnsServices = self.dnsServices;
#if TARGET_OS_IOS
    config.innerSecretKey = [self.innerSecretKey copyWithZone:zone];
    config.innerEnableEncrypt = self.innerEnableEncrypt;
#endif
    
    return config;
}

#pragma mark - SETTINGS

- (void)setReportingNetworkType:(TDReportingNetworkType)reportingNetworkType {
    switch (reportingNetworkType) {
        case TDReportingNetworkTypeWIFI: {
            self.innerNetworkType = ThinkingNetworkTypeWIFI;
        } break;
        case TDReportingNetworkTypeALL: {
            self.innerNetworkType = ThinkingNetworkTypeALL;
        } break;
        default: {
            self.innerNetworkType = ThinkingNetworkTypeALL;
        } break;
    }
}

//MARK: - private

- (ThinkingNetworkType)getNetworkType {
    return self.innerNetworkType;
}

- (void)innerUpdateConfig:(void (^)(NSDictionary *))block {
    NSString *serverUrlStr = [NSString stringWithFormat:@"%@/config",self.serverUrl];
    TDAnalyticsNetwork *network = [[TDAnalyticsNetwork alloc] init];
    network.serverURL = [NSURL URLWithString:serverUrlStr];
    network.securityPolicy = _securityPolicy;
    
    [network fetchRemoteConfig:self.appid handler:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
        if (!error) {
            NSInteger uploadInterval = [[result objectForKey:@"sync_interval"] integerValue];
            NSInteger uploadSize = [[result objectForKey:@"sync_batch_size"] integerValue];
            if (self.enableAutoCalibrated) {
                NSNumber *serverTimestampNum = result[@"server_timestamp"];
                if ([serverTimestampNum isKindOfClass:NSNumber.class]) {
                    NSTimeInterval serverTimestamp = [serverTimestampNum doubleValue] * 0.001;
                    [[TDCalibratedTime sharedInstance] recalibrationWithTimeInterval:serverTimestamp];
                }
            }
            if (uploadInterval != [self->_uploadInterval integerValue] || uploadSize != [self->_uploadSize integerValue]) {
                TDFile *file = [[TDFile alloc] initWithAppid:self.appid];
                if (uploadInterval > 0) {
                    self.uploadInterval = [NSNumber numberWithInteger:uploadInterval];
                    [file archiveUploadInterval:self.uploadInterval];
                    NSString *name = self.getInstanceName ? self.getInstanceName() : self.appid;
                    [[ThinkingAnalyticsSDK instanceWithAppid:name] startFlushTimer];
                }
                if (uploadSize > 0) {
                    self.uploadSize = [NSNumber numberWithInteger:uploadSize];
                    [file archiveUploadSize:self.uploadSize];
                }
            }
            self.disableEvents = [result objectForKey:@"disable_event_list"];
            
            if (block) {
                block([result objectForKey:@"secret_key"]);
            }
        }
    }];
}

- (void)innerUpdateIPMap {
    if (self.dnsServices.count <= 0) {
        return;
    }
    NSString *serverUrlStr = [NSString stringWithFormat:@"%@/sync", self.serverUrl];
    TDAnalyticsNetwork *network = [[TDAnalyticsNetwork alloc] init];
    network.serverURL = [NSURL URLWithString:serverUrlStr];
    network.securityPolicy = self.securityPolicy;
    [network fetchIPMap];
}

- (NSString *)innerGetMapInstanceToken {
    if (self.name && [self.name isKindOfClass:[NSString class]] && self.name.length) {
        return self.name;
    } else {
        return self.appid;
    }
}

//MARK: - Deprecated: public

+ (TDConfig *)defaultTDConfig DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    static dispatch_once_t onceToken;
    static TDConfig * _defaultTDConfig;
    dispatch_once(&onceToken, ^{
        _defaultTDConfig = [TDConfig new];
    });
    return _defaultTDConfig;
}

- (NSString *)getMapInstanceToken DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    return [self innerGetMapInstanceToken];
}

- (void)updateConfig:(void (^)(NSDictionary *))block DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    [self innerUpdateConfig:block];
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    switch (type) {
        case TDNetworkTypeOnlyWIFI: {
            self.reportingNetworkType = TDReportingNetworkTypeWIFI;
        } break;
        case TDNetworkTypeALL: {
            self.reportingNetworkType = TDReportingNetworkTypeALL;
        } break;
        default: {
            self.innerNetworkType = ThinkingNetworkTypeALL;
        } break;
    }
}

//MARK: - Deprecated: setter & geter

- (void)setConfigureURL:(NSString *)configureURL {
    self.serverUrl = configureURL;
}

- (NSString *)configureURL {
    return self.serverUrl;
}

#if TARGET_OS_IOS
- (void)setSecretKey:(TDSecretKey *)secretKey {
    _secretKey = secretKey;
    
    [self enableEncryptWithVersion:secretKey.version publicKey:secretKey.publicKey];
}

- (void)setEnableEncrypt:(BOOL)enableEncrypt {
    _enableEncrypt = enableEncrypt;
    self.innerEnableEncrypt = enableEncrypt;
}
#endif

- (void)setNetworkTypePolicy:(ThinkingNetworkType)networkTypePolicy DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    _networkTypePolicy = networkTypePolicy;
    self.innerNetworkType = networkTypePolicy;
}

- (void)setDebugMode:(ThinkingAnalyticsDebugMode)debugMode DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    _debugMode = debugMode;
    self.mode = (TDMode)debugMode;
}

+ (NSInteger)maxNumEvents DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    NSInteger maxNumEvents = [self _maxNumEventsNumber].integerValue;
    if (maxNumEvents < 5000) {
        maxNumEvents = 5000;
    }
    return maxNumEvents;
}

+ (void)setMaxNumEvents:(NSInteger)maxNumEventsNumber DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    [self _setMaxNumEventsNumber:@(maxNumEventsNumber)];
}

+ (NSInteger)expirationDays DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    NSInteger maxNumEvents = [self _expirationDaysNumber].integerValue;
    return maxNumEvents >= 0 ? maxNumEvents : 10;
}

+ (void)setExpirationDays:(NSInteger)expirationDays DEPRECATED_MSG_ATTRIBUTE("Deprecated"){
    [self _setExpirationDaysNumber:@(expirationDays)];
}

@end
