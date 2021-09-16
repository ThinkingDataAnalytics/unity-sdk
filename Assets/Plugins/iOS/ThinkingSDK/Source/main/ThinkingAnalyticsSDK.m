#import "ThinkingAnalyticsSDKPrivate.h"

#import "TDAutoTrackManager.h"
#import "TDCalibratedTimeWithNTP.h"
#import "TDConfig.h"
#import "TDPublicConfig.h"
#import "TDFile.h"
#import "TDNetwork.h"

#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

@interface TDPresetProperties (ThinkingAnalytics)

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateValuesWithDictionary:(NSDictionary *)dict;

@end

@interface ThinkingAnalyticsSDK ()
@property (atomic, strong)   TDNetwork *network;
@property (atomic, strong)   TDAutoTrackManager *autoTrackManager;
@property (strong,nonatomic) TDFile *file;
@end

@implementation ThinkingAnalyticsSDK

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;
static BOOL isWifi;
static BOOL isWwan;
static TDCalibratedTime *calibratedTime;
static dispatch_queue_t serialQueue;
static dispatch_queue_t networkQueue;

+ (nullable ThinkingAnalyticsSDK *)sharedInstance {
    if (instances.count == 0) {
        TDLogError(@"sharedInstance called before creating a Thinking instance");
        return nil;
    }
    
    return instances[defaultProjectAppid];
}

+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid {
    if (instances[appid]) {
        return instances[appid];
    } else {
        TDLogError(@"sharedInstanceWithAppid called before creating a Thinking instance");
        return nil;
    }
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(TDConfig *)config {
    if (instances[appId]) {
        return instances[appId];
    } else if (![url isKindOfClass:[NSString class]] || url.length == 0) {
        return nil;
    }
    
    return [[self alloc] initWithAppkey:appId withServerURL:url withConfig:config];
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url {
    return [ThinkingAnalyticsSDK startWithAppId:appId withUrl:url withConfig:nil];
}

+ (ThinkingAnalyticsSDK *)startWithConfig:(nullable TDConfig *)config {
    return [ThinkingAnalyticsSDK startWithAppId:config.appid withUrl:config.configureURL withConfig:config];
}

- (instancetype)init:(NSString *)appID {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instances = [NSMutableDictionary dictionary];
            defaultProjectAppid = appID;
        });
    }
    
    return self;
}

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"cn.thinkingdata.%p", (void *)self];
        serialQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)serialQueue {
    return serialQueue;
}

+ (dispatch_queue_t)networkQueue {
    return networkQueue;
}

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init]) {
        serverURL = [self checkServerURL:serverURL];
        _appid = appid;
        _isEnabled = YES;
        _serverURL = serverURL;
        _config = [config copy];
        _config.configureURL = serverURL;
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = kDefaultTimeFormat;
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _timeFormatter.timeZone = config.defaultTimeZone;
        self.file = [[TDFile alloc] initWithAppid:appid];
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        _network = [[TDNetwork alloc] init];
        _network.debugMode = config.debugMode;
        _network.appid = appid;
        _network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
        if (config.debugMode == ThinkingAnalyticsDebugOnly || config.debugMode == ThinkingAnalyticsDebug) {
            _network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug", serverURL]];
        }
        _network.securityPolicy = config.securityPolicy;
    }
    return self;
}

- (instancetype)initWithAppkey:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init:appid]) {
        serverURL = [self checkServerURL:serverURL];
        self.serverURL = serverURL;
        self.appid = appid;
        
        if (!config) {
            config = TDConfig.defaultTDConfig;
        }
        
        _config = [config copy];
        _config.appid = appid;
        _config.configureURL = serverURL;
        
        self.file = [[TDFile alloc] initWithAppid:appid];
        [self retrievePersistedData];
        //次序不能调整
        [_config updateConfig];
        
        self.trackTimer = [NSMutableDictionary dictionary];
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = kDefaultTimeFormat;
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _timeFormatter.timeZone = config.defaultTimeZone;

        _applicationWillResignActive = NO;
        _ignoredViewControllers = [[NSMutableSet alloc] init];
        _ignoredViewTypeList = [[NSMutableSet alloc] init];
        
        self.taskId = UIBackgroundTaskInvalid;
        
        NSString *keyPattern = @"^[a-zA-Z][a-zA-Z\\d_]{0,49}$";
        self.regexKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyPattern];
        NSString *keyAutoTrackPattern = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|screen_name|referrer|title|url|element_id|element_type|element_content|element_position))$";
        self.regexAutoTrackKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyAutoTrackPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        [self setNetRadioListeners];
        
        self.autoTrackManager = [TDAutoTrackManager sharedManager];
        
        _network = [[TDNetwork alloc] init];
        _network.debugMode = config.debugMode;
        _network.appid = appid;
        _network.sessionDidReceiveAuthenticationChallenge = config.securityPolicy.sessionDidReceiveAuthenticationChallenge;
        if (config.debugMode == ThinkingAnalyticsDebugOnly || config.debugMode == ThinkingAnalyticsDebug) {
            _network.serverDebugURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/data_debug",serverURL]];
        }
        _network.serverURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/sync",serverURL]];
        _network.securityPolicy = config.securityPolicy;
        
        [self sceneSupportSetting];
        
#ifdef __IPHONE_13_0
        if (@available(iOS 13.0, *)) {
            if (!_isEnableSceneSupport) {
                [self launchedIntoBackground:config.launchOptions];
            } else if (config.launchOptions && [config.launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
                _relaunchInBackGround = YES;
            } else {
                _relaunchInBackGround = NO;
            }
        }
#else
        [self launchedIntoBackground:config.launchOptions];
#endif
        
        [self startFlushTimer];
        [self setApplicationListeners];
        
        instances[appid] = self;
        
        TDLogInfo(@"Thinking Analytics SDK %@ instance initialized successfully with mode: %@, APP ID: %@, server url: %@, device ID: %@", [TDDeviceInfo libVersion], [self modeEnumToString:config.debugMode], appid, serverURL, [self getDeviceId]);
    }
    return self;
}

- (void)launchedIntoBackground:(NSDictionary *)launchOptions {
    td_dispatch_main_sync_safe(^{
        if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
            if (applicationState == UIApplicationStateBackground) {
                self->_relaunchInBackGround = YES;
            }
        }
    });
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl: %@>", (void *)self, self.appid, self.serverURL];
}

+ (UIApplication *)sharedUIApplication {
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

#pragma mark - EnableTracking
- (void)enableTracking:(BOOL)enabled {
    self.isEnabled = enabled;
    
    dispatch_async(serialQueue, ^{
        [self.file archiveIsEnabled:self.isEnabled];
    });
}

- (BOOL)hasDisabled {
    return !_isEnabled || _isOptOut;
}

- (void)optOutTracking {
    TDLogDebug(@"%@ optOutTracking...", self);
    [self doOptOutTracking];
}

- (void)doOptOutTracking {
    self.isOptOut = YES;
    
    @synchronized (self.trackTimer) {
        [self.trackTimer removeAllObjects];
    }
    
    @synchronized (self.superProperty) {
        self.superProperty = [NSDictionary new];
    }
    
    @synchronized (self.identifyId) {
        self.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    }
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    }
    
    dispatch_async(serialQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:self.appid];
        }
        
        [self.file archiveAccountID:nil];
        [self.file archiveIdentifyId:nil];
        [self.file archiveSuperProperties:nil];
        [self.file archiveOptOut:YES];
    });
}

- (void)optOutTrackingAndDeleteUser {
    TDLogDebug(@"%@ optOutTrackingAndDeleteUser...", self);
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:nil eventType:TD_EVENT_TYPE_USER_DEL];
    eventData.persist = NO;
    [self tdInternalTrack:eventData];
    [self doOptOutTracking];
}

- (void)optInTracking {
    TDLogDebug(@"%@ optInTracking...", self);
    self.isOptOut = NO;
    [self.file archiveOptOut:NO];
}

#pragma mark - LightInstance
- (ThinkingAnalyticsSDK *)createLightInstance {
    ThinkingAnalyticsSDK *lightInstance = [[LightThinkingAnalyticsSDK alloc] initWithAPPID:self.appid withServerURL:self.serverURL withConfig:self.config];
    lightInstance.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    lightInstance.relaunchInBackGround = self.relaunchInBackGround;
    lightInstance.isEnableSceneSupport = self.isEnableSceneSupport;
    return lightInstance;
}

#pragma mark - Persistence
- (void)retrievePersistedData {
    self.accountId = [self.file unarchiveAccountID];
    self.superProperty = [self.file unarchiveSuperProperties];
    self.identifyId = [self.file unarchiveIdentifyID];
    self.isEnabled = [self.file unarchiveEnabled];
    self.isOptOut  = [self.file unarchiveOptOut];
    self.config.uploadSize = [self.file unarchiveUploadSize];
    self.config.uploadInterval = [self.file unarchiveUploadInterval];
    if (self.identifyId.length == 0) {
        self.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    }
    // 兼容老版本
    if (self.accountId.length == 0) {
        self.accountId = [self.file unarchiveAccountID];
        [self.file archiveAccountID:self.accountId];
        [self.file deleteOldLoginId];
    }
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    NSMutableDictionary *event = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSInteger count;
    @synchronized (instances) {
        count = [self.dataQueue addObject:event withAppid:self.appid];
    }
    return count;
}

- (void)deleteAll {
    dispatch_async(serialQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:self.appid];
        }
    });
}

#pragma mark - UIApplication Events
- (void)setApplicationListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
    
}

- (void)setNetRadioListeners {
    if ((_reachability = SCNetworkReachabilityCreateWithName(NULL,"thinkingdata.cn")) != NULL) {
        SCNetworkReachabilityFlags flags;
        BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(_reachability, &flags);
        if (didRetrieveFlags) {
            isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
            isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
        }
        SCNetworkReachabilityContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
        if (SCNetworkReachabilitySetCallback(_reachability, ThinkingReachabilityCallback, &context)) {
            if (!SCNetworkReachabilitySetDispatchQueue(_reachability, serialQueue)) {
                SCNetworkReachabilitySetCallback(_reachability, NULL, NULL);
            }
        }
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDLogDebug(@"%@ application will enter foreground", self);
    
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
        _relaunchInBackGround = NO;
        _appRelaunched = YES;
        dispatch_async(serialQueue, ^{
            if (self.taskId != UIBackgroundTaskInvalid) {
                [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
                self.taskId = UIBackgroundTaskInvalid;
            }
        });
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogDebug(@"%@ application did enter background", self);
    _relaunchInBackGround = NO;
    _applicationWillResignActive = NO;
    
    __block UIBackgroundTaskIdentifier backgroundTask = [[ThinkingAnalyticsSDK sharedUIApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:backgroundTask];
        self.taskId = UIBackgroundTaskInvalid;
    }];
    self.taskId = backgroundTask;
    dispatch_group_t bgGroup = dispatch_group_create();

    dispatch_group_enter(bgGroup);
    dispatch_async(serialQueue, ^{
        NSNumber *currentTimeStamp = @([[NSDate date] timeIntervalSince1970]);
        @synchronized (self.trackTimer) {
            NSArray *keys = [self.trackTimer allKeys];
            for (NSString *key in keys) {
                if ([key isEqualToString:TD_APP_END_EVENT]) {
                    continue;
                }
                NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
                if (eventTimer) {
                    NSNumber *eventBegin = [eventTimer valueForKey:TD_EVENT_START];
                    NSNumber *eventDuration = [eventTimer valueForKey:TD_EVENT_DURATION];
                    double usedTime;
                    if (eventDuration) {
                        usedTime = [currentTimeStamp doubleValue] - [eventBegin doubleValue] + [eventDuration doubleValue];
                    } else {
                        usedTime = [currentTimeStamp doubleValue] - [eventBegin doubleValue];
                    }
                    [eventTimer setObject:[NSNumber numberWithDouble:usedTime] forKey:TD_EVENT_DURATION];
                    self.trackTimer[key] = eventTimer;
                }
            }
        }
        dispatch_group_leave(bgGroup);
    });
    
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        NSString *screenName = NSStringFromClass([[TDAutoTrackManager topPresentedViewController] class]);
        screenName = (screenName == nil) ? @"" : screenName;
        [self autotrack:TD_APP_END_EVENT properties:@{TD_EVENT_PROPERTY_SCREEN_NAME: screenName} withTime:nil];
    }
    
    dispatch_group_enter(bgGroup);
    [self syncWithCompletion:^{
        dispatch_group_leave(bgGroup);
    }];
    
    dispatch_group_notify(bgGroup, dispatch_get_main_queue(), ^{
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application will resign active", self);
    _applicationWillResignActive = YES;
    [self stopFlushTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application did become active", self);
    [self startFlushTimer];
    
    if (_applicationWillResignActive) {
        _applicationWillResignActive = NO;
        return;
    }
    _applicationWillResignActive = NO;
    
    dispatch_async(serialQueue, ^{
        NSNumber *currentTime = @([[NSDate date] timeIntervalSince1970]);
        @synchronized (self.trackTimer) {
            NSArray *keys = [self.trackTimer allKeys];
            for (NSString *key in keys) {
                NSMutableDictionary *eventTimer = [[NSMutableDictionary alloc] initWithDictionary:self.trackTimer[key]];
                if (eventTimer) {
                    [eventTimer setValue:currentTime forKey:TD_EVENT_START];
                    self.trackTimer[key] = eventTimer;
                }
            }
        }
    });
    
    if (_appRelaunched) {
        if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
            [self autotrack:TD_APP_START_EVENT properties:@{TD_RESUME_FROM_BACKGROUND:@(_appRelaunched)} withTime:nil];
        }
        if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
            [self timeEvent:TD_APP_END_EVENT];
        }
    }
}

- (void)sceneSupportSetting {
    NSDictionary *sceneManifest = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIApplicationSceneManifest"];
    if (sceneManifest) {
        NSDictionary *sceneConfig = sceneManifest[@"UISceneConfigurations"];
        if (sceneConfig.count > 0) {
            _isEnableSceneSupport = YES;
        } else {
            _isEnableSceneSupport = NO;
        }
    } else {
        _isEnableSceneSupport = NO;
    }
}

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if ([self hasDisabled])
        return;
        
    [self.config setNetworkType:type];
}

- (ThinkingNetworkType)convertNetworkType:(NSString *)networkType {
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

static void ThinkingReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info) {
    ThinkingAnalyticsSDK *thinking = (__bridge ThinkingAnalyticsSDK *)info;
    if (thinking && [thinking isKindOfClass:[ThinkingAnalyticsSDK class]]) {
        [thinking reachabilityChanged:flags];
    }
}

- (void)reachabilityChanged:(SCNetworkReachabilityFlags)flags {
    isWifi = (flags & kSCNetworkReachabilityFlagsReachable) && !(flags & kSCNetworkReachabilityFlagsIsWWAN);
    isWwan = (flags & kSCNetworkReachabilityFlagsIsWWAN);
}

+ (NSString *)currentRadio {
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

+ (NSString *)getNetWorkStates {
    if (isWifi) {
        return @"WIFI";
    } else if (isWwan) {
        return [self currentRadio];
    } else {
        return @"NULL";
    }
}

#pragma mark - Public

- (void)track:(NSString *)event {
    if ([self hasDisabled])
        return;
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict {
    if ([self hasDisabled])
        return;
    propertiesDict = [self processParameters:propertiesDict withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO];
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:event];
    eventData.properties = [propertiesDict copy];
    eventData.timeValueType = TDTimeValueTypeNone;
    [self tdInternalTrack:eventData];
}

// deprecated  使用 track:properties:time:timeZone: 方法传入
- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict time:(NSDate *)time {
    if ([self hasDisabled])
        return;
    propertiesDict = [self processParameters:propertiesDict withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO];
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:event];
    eventData.properties = [propertiesDict copy];
    eventData.timeString = [_timeFormatter stringFromDate:time];
    eventData.timeValueType = TDTimeValueTypeTimeOnly;
    [self tdInternalTrack:eventData];
}

- (void)track:(NSString *)event properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    if ([self hasDisabled])
        return;
    if (timeZone == nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self track:event properties:properties time:time];
#pragma clang diagnostic pop
        return;
    }
    properties = [self processParameters:properties withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:NO withH5:NO];
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:event];
    eventData.properties = [properties copy];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = kDefaultTimeFormat;
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    timeFormatter.timeZone = timeZone;
    eventData.timeString = [timeFormatter stringFromDate:time];
    eventData.zoneOffset = [self getTimezoneOffset:time timeZone:timeZone];
    eventData.timeValueType = TDTimeValueTypeAll;
    [self tdInternalTrack:eventData];
}

- (void)trackWithEventModel:(TDEventModel *)eventModel {
    NSDictionary *dic = eventModel.properties;
    eventModel.properties = [self processParameters:dic
                                           withType:eventModel.eventType
                                      withEventName:eventModel.eventName
                                      withAutoTrack:NO
                                             withH5:NO];
    [self tdInternalTrack:eventModel];
}

#pragma mark - Private

- (NSString *)checkServerURL:(NSString *)urlString {
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSNumber *port = [url port];
    
    if (scheme && scheme.length>0 && host && host.length>0) {
        urlString = [NSString stringWithFormat:@"%@://%@", scheme, host];
        if (port && [port stringValue]) {
            urlString = [urlString stringByAppendingFormat:@":%@", [port stringValue]];
        }
    }
    return urlString;
}

- (void)h5track:(NSString *)eventName
        extraID:(NSString *)extraID
     properties:(NSDictionary *)propertieDict
           type:(NSString *)type
           time:(NSString *)time {
    
    if ([self hasDisabled])
        return;
    propertieDict = [self processParameters:propertieDict withType:type withEventName:eventName withAutoTrack:NO withH5:YES];
    TDEventModel *eventData;
    
    if (extraID.length > 0) {
        if ([type isEqualToString:TD_EVENT_TYPE_TRACK]) {
            eventData = [[TDEventModel alloc] initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_FIRST];
        } else {
            eventData = [[TDEventModel alloc] initWithEventName:eventName eventType:type];
        }
        eventData.extraID = extraID;
    } else {
        eventData = [[TDEventModel alloc] initWithEventName:eventName];
    }
    eventData.properties = [propertieDict copy];

    if ([propertieDict objectForKey:@"#zone_offset"]) {
        eventData.zoneOffset = [[propertieDict objectForKey:@"#zone_offset"] doubleValue];
        eventData.timeValueType = TDTimeValueTypeAll;
    } else {
        eventData.timeValueType = TDTimeValueTypeTimeOnly;
    }
    eventData.timeString = time;
    [self tdInternalTrack:eventData];
}

- (void)autotrack:(NSString *)event properties:(NSDictionary *)propertieDict withTime:(NSDate *)time {
    if ([self hasDisabled])
        return;
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    [properties addEntriesFromDictionary:propertieDict];
    NSDictionary *superProperty = [NSDictionary dictionary];
    superProperty = [self processParameters:superProperty withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:YES withH5:NO];
    [properties addEntriesFromDictionary:superProperty];
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:event];
    eventData.properties = [properties copy];
    eventData.timeString = [_timeFormatter stringFromDate:time];
    eventData.timeValueType = TDTimeValueTypeNone;
    [self tdInternalTrack:eventData];
}

- (double)getTimezoneOffset:(NSDate *)date timeZone:(NSTimeZone *)timeZone {
    NSTimeZone *tz = timeZone ? timeZone : [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [tz secondsFromGMTForDate:date];
    return (double)sourceGMTOffset/3600;
}

- (void)track:(NSString *)event withProperties:(NSDictionary *)properties withType:(NSString *)type {
    [self track:event withProperties:properties withType:type withTime:nil];
}

- (void)track:(NSString *)event withProperties:(NSDictionary *)properties withType:(NSString *)type withTime:(NSDate *)time {
    if ([self hasDisabled])
        return;
    
    properties = [self processParameters:properties withType:type withEventName:event withAutoTrack:NO withH5:NO];
    TDEventModel *eventData = [[TDEventModel alloc] initWithEventName:event eventType:type];
    eventData.properties = [properties copy];
    if (time) {
        eventData.timeString = [_timeFormatter stringFromDate:time];
        eventData.timeValueType = TDTimeValueTypeTimeOnly;
    } else {
        eventData.timeValueType = TDTimeValueTypeNone;
    }
    [self tdInternalTrack:eventData];
}

+ (BOOL)isTrackEvent:(NSString *)eventType {
    return [TD_EVENT_TYPE_TRACK isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_FIRST isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_UPDATE isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_OVERWRITE isEqualToString:eventType]
    ;
}

#pragma mark - User

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    [self user_add:propertyName andPropertyValue:propertyValue withTime:nil];
}

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate *)time {
    if (propertyName && propertyValue) {
        [self track:nil withProperties:@{propertyName:propertyValue} withType:TD_EVENT_TYPE_USER_ADD withTime:time];
    }
}

- (void)user_add:(NSDictionary *)properties {
    [self user_add:properties withTime:nil];
}

- (void)user_add:(NSDictionary *)properties withTime:(NSDate *)time {
    if ([self hasDisabled])
        return;
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_ADD withTime:time];
}

- (void)user_setOnce:(NSDictionary *)properties {
    [self user_setOnce:properties withTime:nil];
}

- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate *)time {
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_SETONCE withTime:time];
}

- (void)user_set:(NSDictionary *)properties {
    [self user_set:properties withTime:nil];
}

- (void)user_set:(NSDictionary *)properties withTime:(NSDate *)time {
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_SET withTime:time];
}

- (void)user_unset:(NSString *)propertyName {
    [self user_unset:propertyName withTime:nil];
}

- (void)user_unset:(NSString *)propertyName withTime:(NSDate *)time {
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary *properties = @{propertyName: @0};
        [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_UNSET withTime:time];
    }
}

- (void)user_delete {
    [self user_delete:nil];
}

- (void)user_delete:(NSDate *)time {
    [self track:nil withProperties:nil withType:TD_EVENT_TYPE_USER_DEL withTime:time];
}

- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties {
    [self user_append:properties withTime:nil];
}

- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate *)time {
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_APPEND withTime:time];
}

+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion {
    if (libName.length > 0) {
        [TDDeviceInfo sharedManager].libName = libName;
    }
    if (libVersion.length > 0) {
        [TDDeviceInfo sharedManager].libVersion = libVersion;
    }
    [[TDDeviceInfo sharedManager] updateAutomaticData];
}

- (NSString *)getDistinctId {
    return [self.identifyId copy];
}

+ (NSString *)getSDKVersion {
    return TDPublicConfig.version;
}

- (NSString *)getDeviceId {
    return [TDDeviceInfo sharedManager].deviceId;
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties {
    if ([self hasDisabled])
        return;
    self.dynamicSuperProperties = dynamicSuperProperties;
}

- (void)setSuperProperties:(NSDictionary *)properties {
    if ([self hasDisabled])
        return;
    
    if (properties == nil) {
        return;
    }
    properties = [properties copy];
    
    if ([TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone && ![self checkEventProperties:properties withEventType:nil haveAutoTrackEvents:NO]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    @synchronized (self.superProperty) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperty];
        [tmp addEntriesFromDictionary:[properties copy]];
        self.superProperty = [NSDictionary dictionaryWithDictionary:tmp];
    }
    
    dispatch_async(serialQueue, ^{
        [self.file archiveSuperProperties:self.superProperty];
    });
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
    dispatch_async(serialQueue, ^{
        [self.file archiveSuperProperties:self.superProperty];
    });
}

- (void)clearSuperProperties {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.superProperty) {
        self.superProperty = @{};
    }
    
    dispatch_async(serialQueue, ^{
        [self.file archiveSuperProperties:self.superProperty];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperty copy];
}

- (TDPresetProperties *)getPresetProperties {
    NSString *bundleId = [TDDeviceInfo bundleId];
    NSString *networkType = [self.class getNetWorkStates];
    double offset = [self getTimezoneOffset:[NSDate date] timeZone:_config.defaultTimeZone];
    NSDictionary *autoDic = [[TDDeviceInfo sharedManager] collectAutomaticProperties];
    NSMutableDictionary *presetDic = [NSMutableDictionary new];
    [presetDic setObject:bundleId?:@"" forKey:@"#bundle_id"];
    [presetDic setObject:autoDic[@"#carrier"]?:@"" forKey:@"#carrier"];
    [presetDic setObject:autoDic[@"#device_id"]?:@"" forKey:@"#device_id"];
    [presetDic setObject:autoDic[@"#device_model"]?:@"" forKey:@"#device_model"];
    [presetDic setObject:autoDic[@"#manufacturer"]?:@"" forKey:@"#manufacturer"];
    [presetDic setObject:networkType?:@"" forKey:@"#network_type"];
    [presetDic setObject:autoDic[@"#os"]?:@"" forKey:@"#os"];
    [presetDic setObject:autoDic[@"#os_version"]?:@"" forKey:@"#os_version"];
    [presetDic setObject:autoDic[@"#screen_height"]?:@(0) forKey:@"#screen_height"];
    [presetDic setObject:autoDic[@"#screen_width"]?:@(0) forKey:@"#screen_width"];
    [presetDic setObject:autoDic[@"#system_language"]?:@"" forKey:@"#system_language"];
    [presetDic setObject:@(offset)?:@(0) forKey:@"#zone_offset"];
    
    static TDPresetProperties *presetProperties = nil;
    if (presetProperties == nil) {
        presetProperties = [[TDPresetProperties alloc] initWithDictionary:presetDic];
    }
    else {
        [presetProperties updateValuesWithDictionary:presetDic];
    }
    return presetProperties;
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
    }
    dispatch_async(serialQueue, ^{
        [self.file archiveIdentifyId:distinctId];
    });
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
        
    dispatch_async(serialQueue, ^{
        [self.file archiveAccountID:accountId];
    });
}

- (void)logout {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    }
    dispatch_async(serialQueue, ^{
        [self.file archiveAccountID:nil];
    });
}

- (void)timeEvent:(NSString *)event {
    if ([self hasDisabled])
        return;
        
    if (![event isKindOfClass:[NSString class]] || event.length == 0 || ![self isValidName:event isAutoTrack:NO]) {
        NSString *errMsg = [NSString stringWithFormat:@"timeEvent parameter[%@] is not valid", event];
        TDLogError(errMsg);
        return;
    }
    
    NSNumber *eventBegin = @([[NSDate date] timeIntervalSince1970]);
    @synchronized (self.trackTimer) {
        self.trackTimer[event] = @{TD_EVENT_START:eventBegin, TD_EVENT_DURATION:[NSNumber numberWithDouble:0]};
    };
}

- (BOOL)isValidName:(NSString *)name isAutoTrack:(BOOL)isAutoTrack {
    @try {
        if (!isAutoTrack) {
            return [self.regexKey evaluateWithObject:name];
        } else {
            return [self.regexAutoTrackKey evaluateWithObject:name];
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@: %@", self, exception);
        return YES;
    }
}

- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents {
    if (![properties isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    __block BOOL failed = NO;
    [properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![key isKindOfClass:[NSString class]]) {
            NSString *errMsg = [NSString stringWithFormat:@"Property name is not valid. The property KEY must be NSString. got: %@ %@", [key class], key];
            TDLogError(errMsg);
            failed = YES;
        }
        
        if (![self isValidName:key isAutoTrack:haveAutoTrackEvents]) {
            NSString *errMsg = [NSString stringWithFormat:@"Property name[%@] is not valid. The property KEY must be string that starts with English letter, and contains letter, number, and '_'. The max length of the property KEY is 50.", key];
            TDLogError(errMsg);
            failed = YES;
        }
        
        if (![obj isKindOfClass:[NSString class]] &&
            ![obj isKindOfClass:[NSNumber class]] &&
            ![obj isKindOfClass:[NSDate class]] &&
            ![obj isKindOfClass:[NSArray class]]) {
            NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSString, NSNumber, NSDate or NSArray. got: %@ %@. ", [obj class], obj];
            TDLogError(errMsg);
            failed = YES;
        }
        
        if (eventType.length > 0 && [eventType isEqualToString:TD_EVENT_TYPE_USER_ADD]) {
            if (![obj isKindOfClass:[NSNumber class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_add value must be NSNumber. got: %@ %@. ", [obj class], obj];
                TDLogError(errMsg);
                failed = YES;
            }
        }

        if (eventType.length > 0 && [eventType isEqualToString:TD_EVENT_TYPE_USER_APPEND]) {
            if (![obj isKindOfClass:[NSArray class]]) {
                NSString *errMsg = [NSString stringWithFormat:@"user_append value must be NSArray. got: %@ %@. ", [obj class], obj];
                TDLogError(errMsg);
                failed = YES;
            }
        }
        
        if ([obj isKindOfClass:[NSNumber class]]) {
            if ([obj doubleValue] > 9999999999999.999 || [obj doubleValue] < -9999999999999.999) {
                NSString *errMsg = [NSString stringWithFormat:@"The number value [%@] is invalid.", obj];
                TDLogError(errMsg);
                failed = YES;
            }
        }
    }];
    if (failed) {
        return NO;
    }
    
    return YES;
}

- (void)clickFromH5:(NSString *)data {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&err];
    NSString *appid = [eventDict[@"#app_id"] isKindOfClass:[NSString class]] ? eventDict[@"#app_id"] : self.appid;
    id dataArr = eventDict[@"data"];
    if (!err && [dataArr isKindOfClass:[NSArray class]]) {
        NSDictionary *dataInfo = [dataArr objectAtIndex:0];
        if (dataInfo != nil) {
            NSString *type = [dataInfo objectForKey:@"#type"];
            NSString *event_name = [dataInfo objectForKey:@"#event_name"];
            NSString *time = [dataInfo objectForKey:@"#time"];
            NSDictionary *properties = [dataInfo objectForKey:@"properties"];
            
            NSString *extraID;
            
            if ([type isEqualToString:TD_EVENT_TYPE_TRACK]) {
                extraID = [dataInfo objectForKey:@"#first_check_id"];
            } else {
                extraID = [dataInfo objectForKey:@"#event_id"];
            }
            
            NSMutableDictionary *dic = [properties mutableCopy];
            [dic removeObjectForKey:@"#account_id"];
            [dic removeObjectForKey:@"#distinct_id"];
            [dic removeObjectForKey:@"#device_id"];
            [dic removeObjectForKey:@"#lib"];
            [dic removeObjectForKey:@"#lib_version"];
            [dic removeObjectForKey:@"#screen_height"];
            [dic removeObjectForKey:@"#screen_width"];
            
            ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
            if (instance) {
                dispatch_async(serialQueue, ^{
                    [instance h5track:event_name
                              extraID:extraID
                           properties:dic
                                 type:type
                                 time:time];
                });
            } else {
                dispatch_async(serialQueue, ^{
                    [self h5track:event_name
                          extraID:extraID
                       properties:dic
                             type:type
                             time:time];
                });
            }
        }
    }
}

- (void)tdInternalTrack:(TDEventModel *)eventData
{
    if ([self hasDisabled])
        return;
    
    if (_relaunchInBackGround && !_config.trackRelaunchedInBackgroundEvents) {
        return;
    }
    
    NSDictionary *propertiesDict = eventData.properties;
    NSMutableDictionary<NSString *, id> *properties = [NSMutableDictionary dictionary];
    
    NSString *timeString;
    NSDate *nowDate = [NSDate date];
    NSTimeInterval systemUptime = [[NSProcessInfo processInfo] systemUptime];
    double offset = 0;
    if (eventData.timeValueType == TDTimeValueTypeNone) {
        NSDate *currentDate = [NSDate date];
        if ([eventData.eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
            currentDate = [currentDate dateByAddingTimeInterval:-1];
        }
        timeString = [_timeFormatter stringFromDate:currentDate];

        offset = [self getTimezoneOffset:[NSDate date] timeZone:_config.defaultTimeZone];
    } else {
        timeString = eventData.timeString;
        offset = eventData.zoneOffset;
    }
        
    //增加duration
    NSDictionary *eventTimer;
    @synchronized (self.trackTimer) {
        eventTimer = self.trackTimer[eventData.eventName];
        if (eventTimer) {
            [self.trackTimer removeObjectForKey:eventData.eventName];
        }
    }

    if (eventTimer) {
        NSNumber *eventBegin = [eventTimer valueForKey:TD_EVENT_START];
        NSNumber *eventDuration = [eventTimer valueForKey:TD_EVENT_DURATION];
        
        double usedTime;
        NSNumber *currentTimeStamp = @([[NSDate date] timeIntervalSince1970]);
        if (eventDuration) {
            usedTime = [currentTimeStamp doubleValue] - [eventBegin doubleValue] + [eventDuration doubleValue];
        } else {
            usedTime = [currentTimeStamp doubleValue] - [eventBegin doubleValue];
        }
        
        if (usedTime > 0) {
            properties[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", usedTime] floatValue]);
        }
    }
        
    if ([ThinkingAnalyticsSDK isTrackEvent:eventData.eventType]) {
        properties[@"#app_version"] = [TDDeviceInfo sharedManager].appVersion;
        properties[@"#bundle_id"] = [TDDeviceInfo bundleId];
        properties[@"#network_type"] = [[self class] getNetWorkStates];
        
        if (_relaunchInBackGround) {
            properties[@"#relaunched_in_background"] = @YES;
        }
        if (eventData.timeValueType != TDTimeValueTypeTimeOnly) {
            properties[@"#zone_offset"] = @(offset);
        }
        
        [properties addEntriesFromDictionary:[TDDeviceInfo sharedManager].automaticData];
    }

    [properties addEntriesFromDictionary:propertiesDict];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    dataDic[@"#time"] = timeString;
    dataDic[@"#uuid"] = [[NSUUID UUID] UUIDString];
    if ([eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
        /** 首次事件的eventType也是track, 但是会有#first_check_id,
         所以初始化的时候首次事件的eventType是 track_first, 用来判断是否需要extraID */
        dataDic[@"#type"] = TD_EVENT_TYPE_TRACK;
    } else {
        dataDic[@"#type"] = eventData.eventType;
    }
    
    if (self.identifyId.length > 0) {
        dataDic[@"#distinct_id"] = self.identifyId;
    }
    if (properties) {
        dataDic[@"properties"] = [NSDictionary dictionaryWithDictionary:properties];
    }
    if (eventData.eventName.length > 0) {
        dataDic[@"#event_name"] = eventData.eventName;
    }
    
    if (eventData.extraID.length > 0) {
        if ([eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            dataDic[@"#first_check_id"] = eventData.extraID;
        } else if ([eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]
                   || [eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
            dataDic[@"#event_id"] = eventData.extraID;
        }
    }
    
    if (self.accountId.length > 0) {
        dataDic[@"#account_id"] = self.accountId;
    }
    
    if ([self.config.disableEvents containsObject:eventData.eventName]) {
        TDLogDebug(@"disabled data:%@", dataDic);
        return;
    }
    
    if (eventData.persist) {
        dispatch_async(serialQueue, ^{
            NSDictionary *finalDic = dataDic;
            if (eventData.timeValueType == TDTimeValueTypeNone && calibratedTime && !calibratedTime.stopCalibrate) {
                finalDic = [self calibratedTime:dataDic withDate:nowDate withSystemDate:systemUptime withEventData:eventData];
            }
            NSInteger count = 0;
            if (self.config.debugMode == ThinkingAnalyticsDebugOnly || self.config.debugMode == ThinkingAnalyticsDebug) {
                TDLogDebug(@"queueing debug data:%@", finalDic);
                [self flushDebugEvent:finalDic];
                @synchronized (instances) {
                    count = [self.dataQueue sqliteCountForAppid:self.appid];
                }
            } else {
                TDLogDebug(@"queueing data:%@", finalDic);
//                NSError *parseError;
//                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalDic options:NSJSONWritingPrettyPrinted error:&parseError];
//                NSString * str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                TDLogDebug(@"queueing data:%@", str);
                count = [self saveEventsData:finalDic];
            }
            if (count >= [self.config.uploadSize integerValue]) {
                [self flush];
            }
        });
    } else {
        TDLogDebug(@"queueing data flush immediately:%@", dataDic);
        dispatch_async(serialQueue, ^{
            [self flushImmediately:dataDic];
        });
    }
}

- (NSDictionary *)calibratedTime:(NSDictionary *)dataDic withDate:(NSDate *)date withSystemDate:(NSTimeInterval)systemUptime withEventData:(TDEventModel *)eventData {
    NSMutableDictionary *calibratedData = [NSMutableDictionary dictionaryWithDictionary:dataDic];
    NSTimeInterval outTime = systemUptime - calibratedTime.systemUptime;
    NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(calibratedTime.serverTime + outTime)];

    if (calibratedTime.stopCalibrate) {
        return dataDic;
    }
    NSString *timeString = [_timeFormatter stringFromDate:serverDate];
    double offset = [self getTimezoneOffset:serverDate timeZone:_config.defaultTimeZone];
    
    calibratedData[@"#time"] = timeString;
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[calibratedData objectForKey:@"properties"]];

    if ([eventData.eventType isEqualToString:TD_EVENT_TYPE_TRACK]
        && eventData.timeValueType != TDTimeValueTypeTimeOnly) {
        properties[@"#zone_offset"] = @(offset);
    }
    calibratedData[@"properties"] = properties;
    return calibratedData;
}

- (void)flushImmediately:(NSDictionary *)dataDic {
    [self dispatchOnNetworkQueue:^{
        [self.network flushEvents:@[dataDic]];
    }];
}

- (NSDictionary<NSString *,id> *)processParameters:(NSDictionary<NSString *,id> *)propertiesDict withType:(NSString *)eventType withEventName:(NSString *)eventName withAutoTrack:(BOOL)autotrack withH5:(BOOL)isH5 {
    
    BOOL isTrackEvent = [ThinkingAnalyticsSDK isTrackEvent:eventType];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (isTrackEvent) {
        [properties addEntriesFromDictionary:self.superProperty];
        NSDictionary *dynamicSuperPropertiesDict = self.dynamicSuperProperties?[self.dynamicSuperProperties() copy]:nil;
        if (dynamicSuperPropertiesDict && [dynamicSuperPropertiesDict isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:dynamicSuperPropertiesDict];
        }
    }
    if (propertiesDict) {
        if ([propertiesDict isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:propertiesDict];
        } else {
            TDLogDebug(@"The property must be NSDictionary. got: %@ %@", [propertiesDict class], propertiesDict);
        }
    }
    
    if (isTrackEvent && !isH5) {
        if (![eventName isKindOfClass:[NSString class]] || eventName.length == 0) {
            NSString *errMsg = [NSString stringWithFormat:@"Event name is invalid. Event name must be NSString. got: %@ %@", [eventName class], eventName];
            TDLogError(errMsg);
        }
        
        if (![self isValidName:eventName isAutoTrack:NO]) {
            NSString *errMsg = [NSString stringWithFormat:@"Event name[ %@ ] is invalid. Event name must be string that starts with English letter, and contains letter, number, and '_'. The max length of the event name is 50.", eventName];
            TDLogError(@"%@", errMsg);
        }
    }
    
    if (properties && !isH5 && [TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone && ![self checkEventProperties:properties withEventType:eventType haveAutoTrackEvents:autotrack]) {
        NSString *errMsg = [NSString stringWithFormat:@"%@ The data contains invalid key or value.", properties];
        TDLogError(errMsg);
    }
    
    if (properties) {
        NSMutableDictionary<NSString *, id> *propertiesDic = [NSMutableDictionary dictionaryWithDictionary:properties];
        for (NSString *key in [properties keyEnumerator]) {
            if ([properties[key] isKindOfClass:[NSDate class]]) {
                NSString *dateStr = [_timeFormatter stringFromDate:(NSDate *)properties[key]];
                propertiesDic[key] = dateStr;
            } else if ([properties[key] isKindOfClass:[NSArray class]]) {
                NSMutableArray *arrayItem = [properties[key] mutableCopy];
                for (int i = 0; i < arrayItem.count ; i++) {
                    if ([arrayItem[i] isKindOfClass:[NSDate class]]) {
                        NSString *dateStr = [_timeFormatter stringFromDate:(NSDate *)arrayItem[i]];
                        arrayItem[i] = dateStr;
                    }
                }
                propertiesDic[key] = arrayItem;
            }
        }
        
        return [propertiesDic copy];
    }
    
    return nil;
}

- (void)flush {
    [self syncWithCompletion:nil];
}

- (void)flushDebugEvent:(NSDictionary *)data {
    [self dispatchOnNetworkQueue:^{
        [self _syncDebug:data];
    }];
}

- (void)syncWithCompletion:(void (^)(void))handler {
    [self dispatchOnNetworkQueue:^{
        [self _sync];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), handler);
        }
    }];
}

- (NSString*)modeEnumToString:(ThinkingAnalyticsDebugMode)enumVal {
    NSArray *modeEnumArray = [[NSArray alloc] initWithObjects:kModeEnumArray];
    return [modeEnumArray objectAtIndex:enumVal];
}

- (void)_syncDebug:(NSDictionary *)record {
    if (self.config.debugMode == ThinkingAnalyticsDebug || self.config.debugMode == ThinkingAnalyticsDebugOnly) {
        int debugResult = [self.network flushDebugEvents:record withAppid:self.appid];
        if (debugResult == -1) {
            // 降级处理
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                dispatch_async(serialQueue, ^{
                    [self saveEventsData:record];
                });
                
                self.config.debugMode = ThinkingAnalyticsDebugOff;
                self.network.debugMode = ThinkingAnalyticsDebugOff;
            } else if (self.config.debugMode == ThinkingAnalyticsDebugOnly) {
                TDLogDebug(@"The data will be discarded due to this device is not allowed to debug:%@", record);
            }
        }
        else if (debugResult == -2) {
            TDLogDebug(@"Exception occurred when sending message to Server:%@", record);
            if (self.config.debugMode == ThinkingAnalyticsDebug) {
                // 网络异常
                dispatch_async(serialQueue, ^{
                    [self saveEventsData:record];
                });
            }
        }
    } else {
        //防止并发事件未降级
        NSInteger count = [self saveEventsData:record];
        if (count >= [self.config.uploadSize integerValue]) {
            [self flush];
        }
    }
}

- (void)_sync {
    NSString *networkType = [[self class] getNetWorkStates];
    if (!([self convertNetworkType:networkType] & self.config.networkTypePolicy)) {
        return;
    }

    dispatch_async(serialQueue, ^{
        NSArray *recordArray;
        
        @synchronized (instances) {
            recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
        }
        
        BOOL flushSucc = YES;
        while (recordArray.count > 0 && flushSucc) {
            NSUInteger sendSize = recordArray.count;
            flushSucc = [self.network flushEvents:recordArray];
            if (flushSucc) {
                @synchronized (instances) {
                    BOOL ret = [self.dataQueue removeFirstRecords:sendSize withAppid:self.appid];
                    if (!ret) {
                        break;
                    }
                    recordArray = [self.dataQueue getFirstRecords:kBatchSize withAppid:self.appid];
                }
            } else {
                break;
            }
        }
    });
}

- (void)dispatchOnNetworkQueue:(void (^)(void))dispatchBlock {
    dispatch_async(serialQueue, ^{
        dispatch_async(networkQueue, dispatchBlock);
    });
}

#pragma mark - Flush control
- (void)startFlushTimer {
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.config.uploadInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.config.uploadInterval integerValue]
                                                          target:self
                                                        selector:@selector(flush)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    });
}

- (void)stopFlushTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    });
}

#pragma mark - Autotracking
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    if ([self hasDisabled])
        return;
    
    _config.autoTrackEventType = eventType;
    if ([TDDeviceInfo sharedManager].isFirstOpen && (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppInstall)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self autotrack:TD_APP_INSTALL_EVENT properties:nil withTime:nil];
            [self flush];
        });
    }
    
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self timeEvent:TD_APP_END_EVENT];
        });
    }

    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *eventName = _relaunchInBackGround?TD_APP_START_BACKGROUND_EVENT:TD_APP_START_EVENT;
#ifdef __IPHONE_13_0
            if (@available(iOS 13.0, *)) {
                if (_isEnableSceneSupport) {
                    eventName = TD_APP_START_EVENT;
                }
            }
#endif
            [self autotrack:eventName properties:@{TD_RESUME_FROM_BACKGROUND:@(_appRelaunched)} withTime:nil];
            [self flush];
        });
    }
    
    [_autoTrackManager trackWithAppid:self.appid withOption:eventType];
    
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppViewCrash) {
        [self trackCrash];
    }
}

- (void)ignoreViewType:(Class)aClass {
    if ([self hasDisabled])
        return;
        
    dispatch_async(serialQueue, ^{
        [self->_ignoredViewTypeList addObject:aClass];
    });
}

- (BOOL)isViewTypeIgnored:(Class)aClass {
    return [_ignoredViewTypeList containsObject:aClass];
}

- (BOOL)isViewControllerIgnored:(UIViewController *)viewController {
    if (viewController == nil) {
        return false;
    }
    NSString *screenName = NSStringFromClass([viewController class]);
    if (_ignoredViewControllers != nil && _ignoredViewControllers.count > 0) {
        if ([_ignoredViewControllers containsObject:screenName]) {
            return true;
        }
    }
    return false;
}

- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return !(_config.autoTrackEventType & eventType);
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if ([self hasDisabled])
        return;
        
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    
    dispatch_async(serialQueue, ^{
        [self->_ignoredViewControllers addObjectsFromArray:controllers];
    });
}

#pragma mark - H5 tracking
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request {
    if (webView == nil || request == nil || ![request isKindOfClass:NSURLRequest.class]) {
        TDLogInfo(@"showUpWebView request error");
        return NO;
    }
    
    NSString *urlStr = request.URL.absoluteString;
    if (!urlStr) {
        return NO;
    }
    
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length == 0) {
        return NO;
    }
    
    NSString *query = [[request URL] query];
    NSArray *queryItem = [query componentsSeparatedByString:@"="];
    
    if (queryItem.count != 2)
        return YES;
    
    NSString *queryValue = [queryItem lastObject];
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length > 0) {
        if ([self hasDisabled])
            return YES;
        
        NSString *eventData = [queryValue stringByRemovingPercentEncoding];
        if (eventData.length > 0)
            [self clickFromH5:eventData];
    }
    return YES;
}

- (void)wkWebViewGetUserAgent:(void (^)(NSString *))completion {
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    [self.wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
        completion(userAgent);
    }];
}

- (void)addWebViewUserAgent {
    if ([self hasDisabled])
        return;
        
    void (^setUserAgent)(NSString *userAgent) = ^void (NSString *userAgent) {
        if ([userAgent rangeOfString:@"td-sdk-ios"].location == NSNotFound) {
            userAgent = [userAgent stringByAppendingString:@" /td-sdk-ios"];
            
            NSDictionary *userAgentDic = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDic];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    };
    
    dispatch_block_t getUABlock = ^() {
        [self wkWebViewGetUserAgent:^(NSString *userAgent) {
            setUserAgent(userAgent);
        }];
    };
    
    td_dispatch_main_sync_safe(getUABlock);
}

#pragma mark - Logging
+ (void)setLogLevel:(TDLoggingLevel)level {
    [TDLogging sharedInstance].loggingLevel = level;
}

#pragma mark - Crash tracking
-(void)trackCrash {
    [[ThinkingExceptionHandler sharedHandler] addThinkingInstance:self];
}

#pragma mark - Calibrate time

+ (void)calibrateTime:(NSTimeInterval)timestamp {
    calibratedTime = [TDCalibratedTime sharedInstance];
    [[TDCalibratedTime sharedInstance] recalibrationWithTimeInterval:timestamp/1000.];
}

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer {
    if ([ntpServer isKindOfClass:[NSString class]] && ntpServer.length > 0) {
        calibratedTime = [TDCalibratedTimeWithNTP sharedInstance];
        [[TDCalibratedTimeWithNTP sharedInstance] recalibrationWithNtps:@[ntpServer]];
    }
}

// for UNITY
- (NSString *)getTimeString:(NSDate *)date {
    return [_timeFormatter stringFromDate:date];
}

@end

@implementation UIView (ThinkingAnalytics)

- (NSString *)thinkingAnalyticsViewID {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID);
}

- (void)setThinkingAnalyticsViewID:(NSString *)thinkingAnalyticsViewID {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID, thinkingAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)thinkingAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE) boolValue];
}

- (void)setThinkingAnalyticsIgnoreView:(BOOL)thinkingAnalyticsIgnoreView {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE, [NSNumber numberWithBool:thinkingAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

- (NSDictionary *)thinkingAnalyticsIgnoreViewWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID);
}

- (void)setThinkingAnalyticsIgnoreViewWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewIDWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID);
}

- (void)setThinkingAnalyticsViewIDWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewProperties {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES);
}

- (void)setThinkingAnalyticsViewProperties:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewPropertiesWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID);
}

- (void)setThinkingAnalyticsViewPropertiesWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)thinkingAnalyticsDelegate {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE);
}

- (void)setThinkingAnalyticsDelegate:(id)thinkingAnalyticsDelegate {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE, thinkingAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

@end
