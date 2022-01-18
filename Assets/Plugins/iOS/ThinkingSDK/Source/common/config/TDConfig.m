#import "TDConfig.h"

#import "TDNetwork.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDSecurityPolicy.h"
#import "TDFile.h"

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

static TDConfig * _defaultTDConfig;

@implementation TDConfig

TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKMaxCacheSize, _maxNumEventsNumber, _setMaxNumEventsNumber, @10000, NO);
TDSDKSETTINGS_PLIST_SETTING_IMPL(NSNumber, ThinkingSDKExpirationDays, _expirationDaysNumber, _setExpirationDaysNumber, @10, NO);

+ (TDConfig *)defaultTDConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTDConfig = [TDConfig new];
    });
    return _defaultTDConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackRelaunchedInBackgroundEvents = NO;
        _autoTrackEventType = ThinkingAnalyticsEventTypeNone;
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G | ThinkingNetworkType5G;
        _securityPolicy = [TDSecurityPolicy defaultPolicy];
        _defaultTimeZone = [NSTimeZone localTimeZone];
    }
    return self;
}

- (instancetype)initWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl
{
    self = [self init];
    if (self) {
        _appid = appId;
        _configureURL = serverUrl;
    }
    return self;
}


- (void)updateConfig {
    NSString *serverUrlStr = [NSString stringWithFormat:@"%@/config",self.configureURL];
    TDNetwork *network = [[TDNetwork alloc] init];
    network.serverURL = [NSURL URLWithString:serverUrlStr];
    network.securityPolicy = _securityPolicy;
    
    [network fetchRemoteConfig:self.appid handler:^(NSDictionary * _Nonnull result, NSError * _Nullable error) {
        if (!error) {
            NSInteger uploadInterval = [[result objectForKey:@"sync_interval"] integerValue];
            NSInteger uploadSize = [[result objectForKey:@"sync_batch_size"] integerValue];
            if (uploadInterval != [self->_uploadInterval integerValue] || uploadSize != [self->_uploadSize integerValue]) {
                TDFile *file = [[TDFile alloc] initWithAppid:self.appid];
                if (uploadInterval > 0) {
                    self.uploadInterval = [NSNumber numberWithInteger:uploadInterval];
                    [file archiveUploadInterval:self.uploadInterval];
                    NSString *name = self.getInstanceName ? self.getInstanceName() : self.appid;
                    [[ThinkingAnalyticsSDK sharedInstanceWithAppid:name] startFlushTimer];
                }
                if (uploadSize > 0) {
                    self.uploadSize = [NSNumber numberWithInteger:uploadSize];
                    [file archiveUploadSize:self.uploadSize];
                }
            }
            self.disableEvents = [result objectForKey:@"disable_event_list"];
        }
    }];
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if (type == TDNetworkTypeDefault) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G | ThinkingNetworkType5G;
    } else if (type == TDNetworkTypeOnlyWIFI) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI;
    } else if (type == TDNetworkTypeALL) {
        _networkTypePolicy = ThinkingNetworkTypeWIFI | ThinkingNetworkType3G | ThinkingNetworkType4G | ThinkingNetworkType2G | ThinkingNetworkType5G;
    }
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    TDConfig *config = [[[self class] allocWithZone:zone] init];
    config.trackRelaunchedInBackgroundEvents = self.trackRelaunchedInBackgroundEvents;
    config.autoTrackEventType = self.autoTrackEventType;
    config.networkTypePolicy = self.networkTypePolicy;
    config.launchOptions = [self.launchOptions copyWithZone:zone];
    config.debugMode = self.debugMode;
    config.securityPolicy = [self.securityPolicy copyWithZone:zone];
    config.defaultTimeZone = [self.defaultTimeZone copyWithZone:zone];
    config.name = [self.name copy];
    return config;
}

#pragma mark - SETTINGS
+ (NSInteger)maxNumEvents {
    NSInteger maxNumEvents = [self _maxNumEventsNumber].integerValue;
    if (maxNumEvents < 5000) {
        maxNumEvents = 5000;
    }
    return maxNumEvents;
}

+ (void)setMaxNumEvents:(NSInteger)maxNumEventsNumber {
    [self _setMaxNumEventsNumber:@(maxNumEventsNumber)];
}

+ (NSInteger)expirationDays {
    NSInteger maxNumEvents = [self _expirationDaysNumber].integerValue;
    return maxNumEvents >= 0 ? maxNumEvents : 10;
}

+ (void)setExpirationDays:(NSInteger)expirationDays {
    [self _setExpirationDaysNumber:@(expirationDays)];
}

@end
