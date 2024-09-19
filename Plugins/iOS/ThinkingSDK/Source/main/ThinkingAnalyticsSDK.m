#import "ThinkingAnalyticsSDKPrivate.h"

#if TARGET_OS_IOS
#import "TDAutoTrackManager.h"
#import "TDAppLaunchReason.h"
#import "TDPushClickEvent.h"
#endif

#import "TDCalibratedTime.h"
#import "TDConfig.h"
#import "TDPublicConfig.h"
#import "TDFile.h"
#import "TDCheck.h"
#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif
#import "NSString+TDString.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDAppState.h"
#import "TDEventRecord.h"
#import "TDAnalyticsReachability.h"
#import "TDAppLifeCycle.h"
#import "TDAnalytics+Public.h"
#import "TDConfigPrivate.h"

#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

@interface TDPresetProperties (ThinkingAnalytics)

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateValuesWithDictionary:(NSDictionary *)dict;

@end

@interface ThinkingAnalyticsSDK ()
@property (nonatomic, strong) TDEventTracker *eventTracker;
@property (nonatomic, strong) TDFile *file;

#if TARGET_OS_IOS
@property (strong,nonatomic) id thirdPartyManager;
#endif

@property (nonatomic, strong) TDSuperProperty *superProperty;
@property (nonatomic, strong) TDPropertyPluginManager *propertyPluginManager;
@property (nonatomic, strong) TDAppLifeCycle *appLifeCycle;
@property (atomic, assign) BOOL isOptOut;
@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, strong) TDTrackTimer *trackTimer;
@property (atomic, strong) TDSqliteDataQueue *dataQueue;

@end

@implementation ThinkingAnalyticsSDK

static NSLock *g_lock;
static NSMutableDictionary *g_instances;
static NSString *defaultProjectAppid;
static dispatch_queue_t td_trackQueue;

+ (NSString *)defaultAppId {
    return defaultProjectAppid;
}

+ (void)initialize {
    static dispatch_once_t ThinkingOnceToken;
    dispatch_once(&ThinkingOnceToken, ^{
        NSString *queuelabel = [NSString stringWithFormat:@"cn.thinkingdata.%p", (void *)self];
        td_trackQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
        g_lock = [[NSLock alloc] init];
    });
}

+ (dispatch_queue_t)sharedTrackQueue {
    return td_trackQueue;
}

+ (dispatch_queue_t)sharedNetworkQueue {
    return [TDEventTracker td_networkQueue];
}

- (ThinkingAnalyticsSDK *)innerCreateLightInstance {
    ThinkingAnalyticsSDK *lightInstance = [[LightThinkingAnalyticsSDK alloc] initWithAPPID:self.config.appid withServerURL:self.config.serverUrl withConfig:self.config];
    lightInstance.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    lightInstance.propertyPluginManager = self.propertyPluginManager;
    return lightInstance;
}

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init]) {
        self.isEnabled = YES;
        self.config = [config copy];
        
        // random instance name
        NSString *instanceName = [NSUUID UUID].UUIDString;
        self.config.name = instanceName;
        
        self.config.appid = appid;
        self.config.serverUrl = serverURL;
        
        NSString *instanceIdentify = [self instanceAliasNameOrAppId];
        if (!instanceIdentify) {
            return nil;
        }
        
        [g_lock lock];
        g_instances[instanceIdentify] = self;
        [g_lock unlock];
        
        self.superProperty = [[TDSuperProperty alloc] initWithToken:instanceIdentify isLight:YES];
        
        self.trackTimer = [[TDTrackTimer alloc] init];
                
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        self.eventTracker = [[TDEventTracker alloc] initWithQueue:td_trackQueue instanceToken:instanceIdentify];
    }
    return self;
}

- (instancetype)initWithConfig:(TDConfig *)config {
    if (self = [super init]) {
        if (!config) {
            return nil;
        }
        self.config = config;

        NSString *instanceAliasName = [self instanceAliasNameOrAppId];
        if (!instanceAliasName) {
            return nil;
        }

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            g_instances = [NSMutableDictionary dictionary];
            defaultProjectAppid = instanceAliasName;
        });
        
        [TDAnalyticsAppGroupManager shareInstance].appGroupName = self.config.appGroupName;
        [[TDAnalyticsAppGroupManager shareInstance] setReceiveUrl:self.config.serverUrl appId:self.config.appid];
        
        [g_lock lock];
        g_instances[instanceAliasName] = self;
        [g_lock unlock];
        
        self.file = [[TDFile alloc] initWithAppid:instanceAliasName];
        [self retrievePersistedData];
        
        self.superProperty = [[TDSuperProperty alloc] initWithToken:instanceAliasName isLight:NO];
        
        self.propertyPluginManager = [[TDPropertyPluginManager alloc] init];
        TDPresetPropertyPlugin *presetPlugin = [[TDPresetPropertyPlugin alloc] init];
        presetPlugin.defaultTimeZone = config.defaultTimeZone;
        [self.propertyPluginManager registerPropertyPlugin:presetPlugin];
                
        self.config.getInstanceName = ^NSString * _Nonnull{
            return instanceAliasName;
        };
        
        /* remove session plugin
        TASessionIdPropertyPlugin *sessionidPlugin = [[TASessionIdPropertyPlugin alloc] init];
        sessionidPlugin.instanceToken = instanceName;
        self.sessionidPlugin = sessionidPlugin;
        [self.propertyPluginManager registerPropertyPlugin:sessionidPlugin];
         */
        
        //TASensitivePropertyPlugin
        Class c_Sensitive = NSClassFromString(@"TDSensitivePropertyPlugin");
        if (c_Sensitive != nil) {
            id s_Sensitive = [[c_Sensitive alloc] init];
            [s_Sensitive setValue:instanceAliasName forKey:@"_instanceToken"];
            [self.propertyPluginManager registerPropertyPlugin:s_Sensitive];
        }
        
#if TARGET_OS_IOS

        if (self.config.innerEnableEncrypt) {
            self.encryptManager = [[TDEncryptManager alloc] initWithSecretKey:self.config.innerSecretKey];
        }
        
        __weak __typeof(self)weakSelf = self;
        [self.config innerUpdateConfig:^(NSDictionary * _Nonnull secretKey) {
            if (weakSelf.config.innerEnableEncrypt && secretKey) {
                [weakSelf.encryptManager handleEncryptWithConfig:secretKey];
            }
        }];
        
        [self.config innerUpdateIPMap];
      
#elif TARGET_OS_OSX
        [self.config innerUpdateConfig:^(NSDictionary * _Nonnull secretKey) {}];
#endif
        
        self.trackTimer = [[TDTrackTimer alloc] init];
        
        self.ignoredViewControllers = [[NSMutableSet alloc] init];
        self.ignoredViewTypeList = [[NSMutableSet alloc] init];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:instanceAliasName];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
                
        if (![TDPresetProperties disableNetworkType]) {
            [[TDAnalyticsReachability shareInstance] startMonitoring];
        }
        
        self.eventTracker = [[TDEventTracker alloc] initWithQueue:td_trackQueue instanceToken:instanceAliasName];

        [self startFlushTimer];
        
        [TDAppLifeCycle startMonitor];
        
        [self registerAppLifeCycleListener];
        
#if TARGET_OS_IOS
        NSDictionary *ops = [TDAppLaunchReason getAppPushDic];
        if(ops != nil){
            TDPushClickEvent *pushEvent = [[TDPushClickEvent alloc]initWithName: @"te_ops_push_click"];
            pushEvent.ops = ops;
            [self autoTrackWithEvent:pushEvent properties:@{}];
            [self innerFlush];
        }
        [TDAppLaunchReason clearAppPushParams];
#endif
        
        [[TAModuleManager sharedManager] triggerEvent:TAMDidCustomEvent withCustomParam:[TDAnalyticsRouterEventManager sdkInitEvent]];
        
        TDLogInfo(@"initialized successfully!\n AppID: %@ \n ServerUrl: %@ \n Mode: %@ \n TimeZone: %@ \n DeviceID: %@ \n Lib: %@ \n LibVersion: %@", self.config.appid, self.config.serverUrl, [self modeEnumToString:self.config.mode], self.config.defaultTimeZone, [TDAnalytics getDeviceId], [[TDDeviceInfo sharedManager] libName] ,[TDDeviceInfo libVersion]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray<NSDictionary *> *eventCache = [[TDAnalyticsAppGroupManager shareInstance] getExtensionEventCacheWithAppId:self.config.appid];
            if (eventCache.count) {
                for (NSDictionary *event in eventCache) {
                    [self.eventTracker track:event immediately:NO saveOnly:NO];
                }
                [[TDAnalyticsAppGroupManager shareInstance] clearEventCacheWithAppId:self.config.appid];
            }
        });
    }
    return self;
}

- (void)registerAppLifeCycleListener {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTDAppLifeCycleStateWillChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(appStateDidChangeNotification:) name:kTDAppLifeCycleStateDidChangeNotification object:nil];
}

- (NSString*)modeEnumToString:(TDMode)enumVal {
    NSArray *modeEnumArray = [[NSArray alloc] initWithObjects:@"Normal", @"DebugOnly", @"Debug", nil];
    return [modeEnumArray objectAtIndex:enumVal];
}

- (NSString *)instanceAliasNameOrAppId {
    return [self.config innerGetMapInstanceToken];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[ThinkingAnalyticsSDK] AppID: %@, ServerUrl: %@, Mode: %@, TimeZone: %@, DeviceID: %@, Lib: %@, LibVersion: %@", self.config.appid, self.config.serverUrl, [self modeEnumToString:self.config.mode], self.config.defaultTimeZone, [TDAnalytics getDeviceId], [[TDDeviceInfo sharedManager] libName] ,[TDDeviceInfo libVersion]];
}

- (BOOL)hasDisabled {
    return !self.isEnabled || self.isOptOut;
}

- (void)doOptOutTracking {
    self.isOptOut = YES;
    
#if TARGET_OS_IOS
    @synchronized (self.autoTrackSuperProperty) {
        [self.autoTrackSuperProperty clearSuperProperties];
    }
#endif

    [self.superProperty registerDynamicSuperProperties:nil];

    void(^block)(void) = ^{
        [self.dataQueue deleteAll:[self instanceAliasNameOrAppId]];
        [self.trackTimer clear];
        [self.superProperty clearSuperProperties];
        self.identifyId = [TDDeviceInfo sharedManager].uniqueId;
        self.accountId = nil;
    
        [self.file archiveAccountID:nil];
        [self.file archiveIdentifyId:nil];
        [self.file archiveSuperProperties:nil];
        [self.file archiveOptOut:YES];
    };
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(td_trackQueue)) {
        block();
    } else {
        dispatch_async(td_trackQueue, block);
    }
}

#pragma mark - Persistence
- (void)retrievePersistedData {
    self.accountId = [self.file unarchiveAccountID];
    self.identifyId = [self.file unarchiveIdentifyID];
    self.trackPause = [self.file unarchiveTrackPause];
    self.isEnabled = [self.file unarchiveEnabled];
    self.isOptOut  = [self.file unarchiveOptOut];
    self.config.uploadSize = [self.file unarchiveUploadSize];
    self.config.uploadInterval = [self.file unarchiveUploadInterval];
    if (self.identifyId.length == 0) {
        self.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    }
    if (self.accountId.length == 0) {
        [self.file deleteOldLoginId];
    }
    
    [[TDAnalyticsAppGroupManager shareInstance] setAccountId:self.accountId appId:self.config.appid];
    [[TDAnalyticsAppGroupManager shareInstance] setDistinctId:self.identifyId appId:self.config.appid];
    [[TDAnalyticsAppGroupManager shareInstance] setDeviceId:[TDDeviceInfo sharedManager].deviceId appId:self.config.appid];
}

- (void)deleteAll {
    dispatch_async(td_trackQueue, ^{
        @synchronized (TDSqliteDataQueue.class) {
            [self.dataQueue deleteAll:[self instanceAliasNameOrAppId]];
        }
    });
}

//MARK: - AppLifeCycle

- (void)appStateWillChangeNotification:(NSNotification *)notification {
    TDAppLifeCycleState newState = [[notification.userInfo objectForKey:kTDAppLifeCycleNewStateKey] integerValue];
   
    if (newState == TDAppLifeCycleStateEnd) {
        [self stopFlushTimer];
    }
}

- (void)appStateDidChangeNotification:(NSNotification *)notification {
    TDAppLifeCycleState newState = [[notification.userInfo objectForKey:kTDAppLifeCycleNewStateKey] integerValue];

    if (newState == TDAppLifeCycleStateStart) {
        [self startFlushTimer];
        NSTimeInterval systemUpTime = [TDCommonUtil uptime];
        [self.trackTimer enterForegroundWithSystemUptime:systemUpTime];
    } else if (newState == TDAppLifeCycleStateEnd) {
        NSTimeInterval systemUpTime = [TDCommonUtil uptime];
        [self.trackTimer enterBackgroundWithSystemUptime:systemUpTime];
        
#if TARGET_OS_IOS
        UIApplication *application = [TDAppState sharedApplication];;
        __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        void (^endBackgroundTask)(void) = ^() {
            [application endBackgroundTask:backgroundTaskIdentifier];
            backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        };
        backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:endBackgroundTask];
        
        [self.eventTracker _asyncWithCompletion:endBackgroundTask];
#else
        [self.eventTracker flush];
#endif
        
    } else if (newState == TDAppLifeCycleStateTerminate) {
        dispatch_sync(td_trackQueue, ^{});
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.eventTracker syncSendAllData];
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
    }
}

// MARK: -

+ (NSString *)getNetWorkStates {
    return [[TDAnalyticsReachability shareInstance] networkState];
}

#pragma mark - Private

- (void)asyncTrackEventObject:(TDTrackEvent *)event properties:(NSDictionary * _Nullable)properties isH5:(BOOL)isH5 {

    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
    
    [self calibratedTimeWithEvent:event];
    
    dispatch_async(td_trackQueue, ^{
        @autoreleasepool {
            event.dynamicSuperProperties = [self.superProperty obtainDynamicSuperProperties];
            [self trackEvent:event properties:[properties copy] isH5:isH5];
        }
    });
}

- (void)asyncUserEventObject:(TDUserEvent *)event properties:(NSDictionary * _Nullable)properties isH5:(BOOL)isH5 {

    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
    
    [self calibratedTimeWithEvent:event];

    dispatch_async(td_trackQueue, ^{
        @autoreleasepool {
            [self trackUserEvent:event properties:[properties copy] isH5:NO];
        }
    });
}

- (void)calibratedTimeWithEvent:(TDBaseEvent *)event {
    if (event.timeValueType == TDEventTimeValueTypeNone) {
        TDCalibratedTime *calibratedTime = [TDCalibratedTime sharedInstance];
        if (calibratedTime && !calibratedTime.stopCalibrate) {
            NSTimeInterval outTime = [TDCommonUtil uptime] - calibratedTime.systemUptime;
            NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(calibratedTime.serverTime + outTime)];
            event.time = serverDate;
        }
    }
}

+ (BOOL)isTrackEvent:(NSString *)eventType {
    return [TD_EVENT_TYPE_TRACK isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_FIRST isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_UPDATE isEqualToString:eventType]
    || [TD_EVENT_TYPE_TRACK_OVERWRITE isEqualToString:eventType]
    ;
}

//MARK: -

- (void)trackUserEvent:(TDUserEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    
    if (!event.isEnabled || event.isOptOut) {
        return;
    }
    
    if ([TDAppState shareInstance].relaunchInBackground && !self.config.trackRelaunchedInBackgroundEvents) {
        return;
    }
        
    [event.properties addEntriesFromDictionary:[TDPropertyValidator validateProperties:properties validator:event]];
    
    if (event.timeZone == nil) {
        event.timeZone = self.config.defaultTimeZone ?: [NSTimeZone localTimeZone];
    }
    
    NSDictionary *jsonObj = [event formatDateWithDict:event.jsonObject];
    
    [self.eventTracker track:jsonObj immediately:event.immediately saveOnly:event.isTrackPause];
}

- (void)trackEvent:(TDTrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    
    if (!event.isEnabled || event.isOptOut) {
        return;
    }
    
    if ([TDAppState shareInstance].relaunchInBackground && !self.config.trackRelaunchedInBackgroundEvents && [event.eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT]) {
        return;
    }
        
    NSError *error = nil;
    [event validateWithError:&error];
    if (error) {
        return;
    }
    
    if ([self.config.disableEvents containsObject:event.eventName]) {
        return;
    }

    
    if ([TDAppState shareInstance].relaunchInBackground) {
        event.properties[@"#relaunched_in_background"] = @YES;
    }
    
    NSMutableDictionary *pluginProperties = [self.propertyPluginManager propertiesWithEventType:event.eventType];
    
    [TDPresetProperties handleFilterDisPresetProperties:pluginProperties];
    
    NSDictionary *superProperties = [TDPropertyValidator validateProperties:self.superProperty.currentSuperProperties validator:event];
    
    NSDictionary *dynamicSuperProperties = [TDPropertyValidator validateProperties:event.dynamicSuperProperties validator:event];
    
    if (event.timeZone == nil) {
        event.timeZone = self.config.defaultTimeZone ?: [NSTimeZone localTimeZone];
    }
    
    NSMutableDictionary *jsonObj = [NSMutableDictionary dictionary];

    if (isH5) {
        event.properties = [superProperties mutableCopy];
        [event.properties addEntriesFromDictionary:dynamicSuperProperties];
        [event.properties addEntriesFromDictionary:properties];
        [event.properties addEntriesFromDictionary:pluginProperties];

        jsonObj = event.jsonObject;

        if (event.h5TimeString) {
            jsonObj[@"#time"] = event.h5TimeString;
        }
        if (event.h5ZoneOffSet) {
            jsonObj[@"#zone_offset"] = event.h5ZoneOffSet;
        }
    } else {
        [event.properties addEntriesFromDictionary:pluginProperties];

        jsonObj = event.jsonObject;
        [event.properties addEntriesFromDictionary:superProperties];
        [event.properties addEntriesFromDictionary:dynamicSuperProperties];
#if TARGET_OS_IOS
        if ([event isKindOfClass:[TDAutoTrackEvent class]]) {
            TDAutoTrackEvent *autoEvent = (TDAutoTrackEvent *)event;

            NSDictionary *autoSuperProperties = [self.autoTrackSuperProperty currentSuperPropertiesWithEventName:event.eventName];

            autoSuperProperties = [TDPropertyValidator validateProperties:autoSuperProperties validator:autoEvent];

            [event.properties addEntriesFromDictionary:autoSuperProperties];

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *autoDynamicSuperProperties = [self.autoTrackSuperProperty obtainDynamicSuperPropertiesWithType:autoEvent.autoTrackEventType currentProperties:event.properties];
                autoDynamicSuperProperties = [TDPropertyValidator validateProperties:autoDynamicSuperProperties validator:autoEvent];
                [event.properties addEntriesFromDictionary:autoDynamicSuperProperties];

                dispatch_semaphore_signal(semaphore);
            });

            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
        }
#endif
        properties = [TDPropertyValidator validateProperties:properties validator:event];
        [event.properties addEntriesFromDictionary:properties];
    }

    jsonObj = [event formatDateWithDict:jsonObj];

    [self.eventTracker track:jsonObj immediately:event.immediately saveOnly:event.isTrackPause];
}

#pragma mark - innerFlush control
- (void)startFlushTimer {
    [self stopFlushTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.config.uploadInterval > 0) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:[self.config.uploadInterval integerValue]
                                                          target:self
                                                        selector:@selector(autoFlushWithTimer:)
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

#if TARGET_OS_IOS

//MARK: - Auto Track

- (void)autoTrackWithEvent:(TDAutoTrackEvent *)event properties:(NSDictionary *)properties {
    [self handleTimeEvent:event];
    [self asyncAutoTrackEventObject:event properties:properties];
}

/// Add event to event queue
- (void)asyncAutoTrackEventObject:(TDAutoTrackEvent *)event properties:(NSDictionary *)properties {
    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
        
    [self calibratedTimeWithEvent:event];
    
    NSDictionary *autoTrackDynamicProperties = [self.autoTrackSuperProperty obtainAutoTrackDynamicSuperProperties];
    NSDictionary *dynamicProperties = [self.superProperty obtainDynamicSuperProperties];
    NSMutableDictionary *unionProperties = [NSMutableDictionary dictionary];
    if (dynamicProperties) {
        [unionProperties addEntriesFromDictionary:dynamicProperties];
    }
    if (autoTrackDynamicProperties) {
        [unionProperties addEntriesFromDictionary:autoTrackDynamicProperties];
    }
    event.dynamicSuperProperties = unionProperties;
    dispatch_async(td_trackQueue, ^{
        [self trackEvent:event properties:[properties copy] isH5:NO];
    });
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

- (TDAutoTrackSuperProperty *)autoTrackSuperProperty {
    if (!_autoTrackSuperProperty) {
        _autoTrackSuperProperty = [[TDAutoTrackSuperProperty alloc] init];
    }
    return _autoTrackSuperProperty;
}

#endif

//MARK: - Private

- (void)handleTimeEvent:(TDTrackEvent *)trackEvent {
    BOOL isTrackDuration = [self.trackTimer isExistEvent:trackEvent.eventName];
    BOOL isEndEvent = [trackEvent.eventName isEqualToString:TD_APP_END_EVENT];
    BOOL isStartEvent = [trackEvent.eventName isEqualToString:TD_APP_START_EVENT];
    BOOL isStateInit = [TDAppLifeCycle shareInstance].state == TDAppLifeCycleStateInit;
    
    if (isStateInit) {
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:YES systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else if (isStartEvent) {
        trackEvent.backgroundDuration = [self.trackTimer backgroundDurationOfEvent:trackEvent.eventName isActive:NO systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else if (isEndEvent) {
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:YES systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else if (isTrackDuration) {
        BOOL isActive = [TDAppState shareInstance].isActive;
        trackEvent.foregroundDuration = [self.trackTimer foregroundDurationOfEvent:trackEvent.eventName isActive:isActive systemUptime:trackEvent.systemUpTime];
        trackEvent.backgroundDuration = [self.trackTimer backgroundDurationOfEvent:trackEvent.eventName isActive:isActive systemUptime:trackEvent.systemUpTime];
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else {
        if (trackEvent.eventName == TD_APP_END_EVENT) {
            return;
        }
    }
}

+ (NSMutableDictionary *)_getAllInstances {
    NSMutableDictionary *dict = nil;
    [g_lock lock];
    dict = [g_instances mutableCopy];
    [g_lock unlock];
    return dict;
}

+ (void)track_crashEventWithMessage:(NSString *)msg {
#if TARGET_OS_IOS
    [ThinkingExceptionHandler trackCrashWithMessage:msg];
#endif
}

//MARK: - SDK instance

+ (nullable ThinkingAnalyticsSDK *)defaultInstance {
    NSString *appId = [self defaultAppId];
    return [self instanceWithAppid:appId];
}

+ (nullable ThinkingAnalyticsSDK *)instanceWithAppid:(NSString *)appid {
    appid = appid.td_trim;
    if (appid == nil || appid.length == 0) {
        appid = [ThinkingAnalyticsSDK defaultAppId];
    }
    ThinkingAnalyticsSDK *sdk = nil;
    [g_lock lock];
    sdk = g_instances[appid];
    [g_lock unlock];
    return sdk;
}

//MARK: - track event

- (void)innerTrack:(NSString *)event {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self innerTrack:event properties:nil time:nil timeZone:nil];
#pragma clang diagnostic pop
}
- (void)innerTrack:(NSString *)event properties:(NSDictionary *)propertieDict {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self innerTrack:event properties:propertieDict time:nil timeZone:nil];
#pragma clang diagnostic pop
}
- (void)innerTrack:(NSString *)event properties:(NSDictionary * _Nullable)propertieDict time:(nonnull NSDate *)time timeZone:(nonnull NSTimeZone *)timeZone {
    TDTrackEvent *trackEvent = [[TDTrackEvent alloc] initWithName:event];
    if (time) {
        trackEvent.time = time;
        trackEvent.timeValueType = TDEventTimeValueTypeTimeOnly;
        if (timeZone) {
            trackEvent.timeZone = timeZone;
            trackEvent.timeValueType = TDEventTimeValueTypeTimeAndZone;
        }
    }
    [self handleTimeEvent:trackEvent];
    [self asyncTrackEventObject:trackEvent properties:propertieDict isH5:NO];
}
- (void)innerTrackWithEventModel:(TDEventModel *)eventModel {
    TDTrackEvent *baseEvent = nil;
    if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
        TDTrackFirstEvent *trackEvent = [[TDTrackFirstEvent alloc] initWithName:eventModel.eventName];
        trackEvent.firstCheckId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
        TDTrackUpdateEvent *trackEvent = [[TDTrackUpdateEvent alloc] initWithName:eventModel.eventName];
        trackEvent.eventId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        TDTrackOverwriteEvent *trackEvent = [[TDTrackOverwriteEvent alloc] initWithName:eventModel.eventName];
        trackEvent.eventId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK]) {
        TDTrackEvent *trackEvent = [[TDTrackEvent alloc] initWithName:eventModel.eventName];
        baseEvent = trackEvent;
    }
    
    if (eventModel.time) {
        baseEvent.time = eventModel.time;
        baseEvent.timeValueType = TDEventTimeValueTypeTimeOnly;
        if (eventModel.timeZone) {
            baseEvent.timeZone = eventModel.timeZone;
            baseEvent.timeValueType = TDEventTimeValueTypeTimeAndZone;
        }
    }
    
    [self asyncTrackEventObject:baseEvent properties:eventModel.properties isH5:NO];
}
- (void)innerTimeEvent:(NSString *)event {
    if ([self hasDisabled]) {
        return;
    }
    NSError *error = nil;
    [TDPropertyValidator validateEventOrPropertyName:event withError:&error];
    if (error) {
        return;
    }
    [self.trackTimer trackEvent:event withSystemUptime:[TDCommonUtil uptime]];
}

//MARK: - user id

- (void)innerSetIdentify:(NSString *)distinctId {
    if ([self hasDisabled]) {
        return;
    }
    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    
    TDLogInfo(@"Set distinct ID, Distinct Id = %@", distinctId);
    
    self.identifyId = distinctId;
    @synchronized (self.file) {
        [self.file archiveIdentifyId:distinctId];
    }
    
    [[TAModuleManager sharedManager] triggerEvent:TAMDidCustomEvent withCustomParam:[TDAnalyticsRouterEventManager sdkSetDistinctIdEvent]];
}

- (NSString *)innerDistinctId {
    return self.identifyId;
}

- (NSString *)innerAccountId {
    return self.accountId;
}

// TAThirdParty model used.
- (NSString *)getAccountId {
    return [self innerAccountId];
}

- (void)innerLogin:(NSString *)accountId {
    if ([self hasDisabled]) {
        return;
    }
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }
    
    TDLogInfo(@"Login SDK, AccountId = %@", accountId);
    
    self.accountId = accountId;
    @synchronized (self.file) {
        [self.file archiveAccountID:accountId];
    }
    [[TDAnalyticsAppGroupManager shareInstance] setAccountId:self.accountId appId:self.config.appid];
    [[TAModuleManager sharedManager] triggerEvent:TAMDidCustomEvent withCustomParam:[TDAnalyticsRouterEventManager sdkLoginEvent]];
}
- (void)innerLogout {
    if ([self hasDisabled]) {
        return;
    }
    
    TDLogInfo(@"Logout SDK.");
    
    self.accountId = nil;
    @synchronized (self.file) {
        [self.file archiveAccountID:nil];
    }
    [[TDAnalyticsAppGroupManager shareInstance] setAccountId:nil appId:self.config.appid];
    [[TAModuleManager sharedManager] triggerEvent:TAMDidCustomEvent withCustomParam:[TDAnalyticsRouterEventManager sdkLogoutEvent]];
}

//MARK: - user profile

- (void)innerUserSet:(NSDictionary *)properties {
    TDUserEventSet *event = [[TDUserEventSet alloc] init];
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)innerUserUnset:(NSString *)propertyName {
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary *properties = @{propertyName: @0};
        TDUserEventUnset *event = [[TDUserEventUnset alloc] init];
        [self asyncUserEventObject:event properties:properties isH5:NO];
    }
}
- (void)innerUserUnsets:(NSArray<NSString *> *)propertyNames {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *name in propertyNames) {
        if ([name isKindOfClass:[NSString class]] && name.length > 0) {
            dict[name] = @0;
        }
    }
    if (dict.count > 0) {
        TDUserEventUnset *event = [[TDUserEventUnset alloc] init];
        [self asyncUserEventObject:event properties:dict isH5:NO];
    }
}
- (void)innerUserSetOnce:(NSDictionary *)properties {
    TDUserEventSetOnce *event = [[TDUserEventSetOnce alloc] init];
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

- (void)innerUserAdd:(NSDictionary *)properties {
    TDUserEventAdd *event = [[TDUserEventAdd alloc] init];
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)innerUserAdd:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    if (propertyName && propertyValue) {
        [self innerUserAdd:@{propertyName: propertyValue}];
    }
}
- (void)innerUserDelete {
    TDUserEventDelete *event = [[TDUserEventDelete alloc] init];
    [self asyncUserEventObject:event properties:nil isH5:NO];
}
- (void)innerUserAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    TDUserEventAppend *event = [[TDUserEventAppend alloc] init];
    [self asyncUserEventObject:event properties:properties isH5:NO];
}
- (void)innerUserUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    TDUserEventUniqueAppend *event = [[TDUserEventUniqueAppend alloc] init];
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

//MARK: - super properties

- (void)innerSetSuperProperties:(NSDictionary *)properties {
    if ([self hasDisabled]) {
        return;
    }
    
    dispatch_async(td_trackQueue, ^{
        [self.superProperty registerSuperProperties:properties];
    });
}
- (void)innerUnsetSuperProperty:(NSString *)property {
    if ([self hasDisabled]) {
        return;
    }
    dispatch_async(td_trackQueue, ^{
        [self.superProperty unregisterSuperProperty:property];
    });
}
- (void)innerClearSuperProperties {
    if ([self hasDisabled]) {
        return;
    }
    dispatch_async(td_trackQueue, ^{
        [self.superProperty clearSuperProperties];
    });
}
- (NSDictionary *)innerCurrentSuperProperties {
    return [self.superProperty currentSuperProperties];
}

- (void)innerRegisterDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties {
    if ([self hasDisabled]) {
        return;
    }
    @synchronized (self.superProperty) {
        [self.superProperty registerDynamicSuperProperties:dynamicSuperProperties];
    }
}

- (TDPresetProperties *)innerGetPresetProperties {
    NSMutableDictionary *presetDic = [NSMutableDictionary dictionary];

    NSDictionary *pluginProperties = [self.propertyPluginManager currentPropertiesForPluginClasses:@[TDPresetPropertyPlugin.class]];
    [presetDic addEntriesFromDictionary:pluginProperties];
    
    double offset = [[NSDate date] ta_timeZoneOffset:self.config.defaultTimeZone];
    [presetDic setObject:@(offset) forKey:@"#zone_offset"];
    
    if (![TDPresetProperties disableNetworkType]) {
        NSString *networkType = [self.class getNetWorkStates];
        [presetDic setObject:networkType?:@"" forKey:@"#network_type"];
    }
    
    if (![TDPresetProperties disableInstallTime]) {
        if (presetDic[@"#install_time"] && [presetDic[@"#install_time"] isKindOfClass:[NSDate class]]) {
            NSString *install_timeString = [(NSDate *)presetDic[@"#install_time"] ta_formatWithTimeZone:self.config.defaultTimeZone formatString:kDefaultTimeFormat];
            if (install_timeString && install_timeString.length) {
                [presetDic setObject:install_timeString forKey:@"#install_time"];
            }
        }
    }
    
    static TDPresetProperties *presetProperties = nil;
    if (presetProperties == nil) {
        presetProperties = [[TDPresetProperties alloc] initWithDictionary:presetDic];
    } else {
        [g_lock lock];
        [presetProperties updateValuesWithDictionary:presetDic];
        [g_lock unlock];
    }
    
    return presetProperties;
}

//MARK: - SDK error callback

- (void)innerRegisterErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback {
    self.errorCallback = errorCallback;
}

//MARK: -

- (BOOL)innerIsViewTypeIgnored:(Class)aClass {
    return [self.ignoredViewTypeList containsObject:aClass];
}

- (void)autoFlushWithTimer:(NSTimer *)timer {
    if ([self hasDisabled] || self.isTrackPause) {
        return;
    }
    [self.eventTracker flush];
}

- (void)innerFlush {
    if ([self hasDisabled] || self.isTrackPause) {
        return;
    }
    TDLogInfo(@"flush data by manual.");
    [self.eventTracker flush];
}

- (void)innerSetNetworkType:(TDReportingNetworkType)type {
    if ([self hasDisabled]) {
        return;
    }
    self.config.reportingNetworkType = type;
}

- (void)innerSetTrackStatus: (TDTrackStatus)status {
    switch (status) {
        case TDTrackStatusPause: {
            TDLogInfo(@"Change status to Pause")
            self.isEnabled = NO;
            dispatch_async(td_trackQueue, ^{
                [self.file archiveIsEnabled:NO];
            });
            break;
        }
        case TDTrackStatusStop: {
            TDLogInfo(@"Change status to Stop")
            [self doOptOutTracking];
            break;
        }
        case TDTrackStatusSaveOnly: {
            TDLogInfo(@"Change status to SaveOnly")
            self.trackPause = YES;
            self.isEnabled = YES;
            self.isOptOut = NO;
            dispatch_async(td_trackQueue, ^{
                [self.file archiveTrackPause:YES];
                [self.file archiveIsEnabled:YES];
                [self.file archiveOptOut:NO];
            });
            break;
        }
        case TDTrackStatusNormal: {
            TDLogInfo(@"Change status to Normal")
            self.trackPause = NO;
            self.isEnabled = YES;
            self.isOptOut = NO;
            dispatch_async(td_trackQueue, ^{
                [self.file archiveTrackPause:NO];
                [self.file archiveIsEnabled:self.isEnabled];
                [self.file archiveOptOut:NO];
            });
            [self innerFlush];
            break;
        }
        default:
            break;
    }
}

- (NSString *)innetGetTimeString:(NSDate *)date {
    return [date ta_formatWithTimeZone:self.config.defaultTimeZone formatString:kDefaultTimeFormat];
}

@end
