#import "ThinkingAnalyticsSDKPrivate.h"

#if TARGET_OS_IOS
#import "TDAutoTrackManager.h"
//#import "TARouter.h"
#import "TDAppLaunchReason.h"
#import "TAPushClickEvent.h"
#endif

#import "TDCalibratedTimeWithNTP.h"
#import "TDConfig.h"
#import "TDPublicConfig.h"
#import "TDFile.h"
#import "TDCheck.h"
#import "TDJSONUtil.h"
#import "NSString+TDString.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDAppState.h"
#import "TDEventRecord.h"
#import "TAAppExtensionAnalytic.h"
#import "TAReachability.h"
#import "TAAppLifeCycle.h"
//#import "TASessionIdPropertyPlugin.h"
//#import "TASessionIdManager.h"


#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

#define td_force_inline __inline__ __attribute__((always_inline))

@interface TDPresetProperties (ThinkingAnalytics)

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateValuesWithDictionary:(NSDictionary *)dict;

@end

@interface ThinkingAnalyticsSDK ()
@property (nonatomic, strong) TAEventTracker *eventTracker;
@property (strong,nonatomic) TDFile *file;

@end

@implementation ThinkingAnalyticsSDK

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;
static TDCalibratedTime *calibratedTime;
static dispatch_queue_t td_trackQueue;

+ (nullable ThinkingAnalyticsSDK *)sharedInstance {
    if (instances.count == 0) {
        TDLogError(@"sharedInstance called before creating a Thinking instance");
        return nil;
    }
    return instances[defaultProjectAppid];
}

+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid {
    appid = appid.td_trim;
    if (instances[appid]) {
        return instances[appid];
    } else {
        TDLogError(@"sharedInstanceWithAppid called before creating a Thinking instance");
        return nil;
    }
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(TDConfig *)config {
    appId = appId.td_trim;
    
    NSString *name = config.name;
    if (name && [name isKindOfClass:[NSString class]] && name.length) {
        if (instances[name]) {
            return instances[name];
        } else {
            return [[self alloc] initWithAppkey:appId withServerURL:url withConfig:config];
        }
    }
    
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
        td_trackQueue = dispatch_queue_create([queuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)td_trackQueue {
    return td_trackQueue;
}

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init]) {
        serverURL = [serverURL ta_formatUrlString];
        self.isEnabled = YES;
        
        self.appid = appid;
        self.serverURL = serverURL;
        self.config = [config copy];
        self.config.appid = appid;
        self.config.configureURL = serverURL;
        self.config.appid = appid;
        
        self.superProperty = [[TASuperProperty alloc] initWithToken:[self td_getMapInstanceTag] isLight:YES];
        
        self.trackTimer = [[TATrackTimer alloc] init];
        
        if (![TDPresetProperties disableNetworkType]) {
            [[TAReachability shareInstance] startMonitoring];
        }
        
        self.file = [[TDFile alloc] initWithAppid:appid];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:appid];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
        
        self.eventTracker = [[TAEventTracker alloc] initWithQueue:td_trackQueue instanceToken:[config getMapInstanceToken]];
    }
    return self;
}

- (instancetype)initWithAppkey:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init:appid]) {
        
        [TDAppState shareInstance];
        // [TASessionIdManager shareInstance];
        
        serverURL = [serverURL ta_formatUrlString];
        self.serverURL = serverURL;
        self.appid = appid;
        
        if (!config) {
            config = TDConfig.defaultTDConfig;
        }
        
        _config = [config copy];
        _config.appid = appid;
        _config.configureURL = serverURL;
        
        instances[[self td_getMapInstanceTag]] = self;

        self.file = [[TDFile alloc] initWithAppid:[self td_getMapInstanceTag]];
        [self retrievePersistedData];
        
        self.superProperty = [[TASuperProperty alloc] initWithToken:[self td_getMapInstanceTag] isLight:NO];
        
        self.propertyPluginManager = [[TAPropertyPluginManager alloc] init];
        TAPresetPropertyPlugin *presetPlugin = [[TAPresetPropertyPlugin alloc] init];
        presetPlugin.defaultTimeZone = config.defaultTimeZone;
        [self.propertyPluginManager registerPropertyPlugin:presetPlugin];
        
        NSString *instanceName = [self td_getMapInstanceTag];
        
        _config.getInstanceName = ^NSString * _Nonnull{
            return instanceName;
        };
        
        /* remove session plugin
        TASessionIdPropertyPlugin *sessionidPlugin = [[TASessionIdPropertyPlugin alloc] init];
        sessionidPlugin.instanceToken = instanceName;
        self.sessionidPlugin = sessionidPlugin;
        [self.propertyPluginManager registerPropertyPlugin:sessionidPlugin];
         */
#if TARGET_OS_IOS

        if (_config.enableEncrypt) {
            self.encryptManager = [[TDEncryptManager alloc] initWithConfig:config];
        }
        
        __weak __typeof(self)weakSelf = self;
        [_config updateConfig:^(NSDictionary * _Nonnull secretKey) {
            if (weakSelf.config.enableEncrypt && secretKey) {
                [weakSelf.encryptManager handleEncryptWithConfig:secretKey];
            }
        }];
      
#elif TARGET_OS_OSX
        [_config updateConfig:^(NSDictionary * _Nonnull secretKey) {}];
#endif
        
        self.trackTimer = [[TATrackTimer alloc] init];
        
        _ignoredViewControllers = [[NSMutableSet alloc] init];
        _ignoredViewTypeList = [[NSMutableSet alloc] init];
                
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:[self td_getMapInstanceTag]];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
                
        if (![TDPresetProperties disableNetworkType]) {
            [[TAReachability shareInstance] startMonitoring];
        }
        
        self.eventTracker = [[TAEventTracker alloc] initWithQueue:td_trackQueue instanceToken:[_config getMapInstanceToken]];

        [self startFlushTimer];
        
        [TAAppLifeCycle startMonitor];
        
        [self registerAppLifeCycleListener];
        
#if TARGET_OS_IOS
        NSDictionary* ops = [TDAppLaunchReason getAppPushDic];
        if(ops != nil){
            TAPushClickEvent *pushEvent = [[TAPushClickEvent alloc]initWithName: @"ops_push_click"];
            pushEvent.ops = ops;
            [self autoTrackWithEvent:pushEvent properties:@{}];
            [self flush];
        }
        [TDAppLaunchReason clearAppPushParams];
#endif
        
        if ([self ableMapInstanceTag]) {
            TDLogInfo(@"Thinking Analytics %@ SDK %@ instance initialized successfully with mode: %@, Instance Name: %@,  APP ID: %@, server url: %@, device ID: %@", [[TDDeviceInfo sharedManager] libName] ,[TDDeviceInfo libVersion], [self modeEnumToString:_config.debugMode], _config.name, appid, serverURL, [self getDeviceId]);

        } else {
            TDLogInfo(@"Thinking Analytics %@ SDK %@ instance initialized successfully with mode: %@, APP ID: %@, server url: %@, device ID: %@", [[TDDeviceInfo sharedManager] libName], [TDDeviceInfo libVersion], [self modeEnumToString:_config.debugMode], appid, serverURL, [self getDeviceId]);

        }
        
    }
    return self;
}

- (void)registerAppLifeCycleListener {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTAAppLifeCycleStateWillChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(appStateDidChangeNotification:) name:kTAAppLifeCycleStateDidChangeNotification object:nil];
}

- (NSString*)modeEnumToString:(ThinkingAnalyticsDebugMode)enumVal {
    NSArray *modeEnumArray = [[NSArray alloc] initWithObjects:kModeEnumArray];
    return [modeEnumArray objectAtIndex:enumVal];
}

- (BOOL)ableMapInstanceTag {
    return _config.name && [_config.name isKindOfClass:[NSString class]] && _config.name.length;
}

- (NSString *)td_getMapInstanceTag {
    return [self.config getMapInstanceToken];
}

- (NSString *)description {
    if ([self ableMapInstanceTag]) {
        return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - instanceName: %@ appid: %@ serverUrl: %@>", (void *)self, _config.name, self.appid, self.serverURL];
    } else {
        return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl: %@>", (void *)self, self.appid, self.serverURL];
    }
}

+ (id)sharedUIApplication {
    return [TDAppState sharedApplication];
}

- (void)setTrackStatus: (TATrackStatus)status {
    switch (status) {
        case TATrackStatusPause: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusPause...", self);
            [self enableTracking:NO];
            break;
        }
        case TATrackStatusStop: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusStop...", self);
            [self doOptOutTracking];
            break;
        }
        case TATrackStatusSaveOnly: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusSaveOnly...", self);
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
        case TATrackStatusNormal: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusNormal...", self);
            self.trackPause = NO;
            self.isEnabled = YES;
            self.isOptOut = NO;
            dispatch_async(td_trackQueue, ^{
                [self.file archiveTrackPause:NO];
                [self.file archiveIsEnabled:self.isEnabled];
                [self.file archiveOptOut:NO];
            });
            [self flush];
            break;
        }
        default:
            break;
    }
}

#pragma mark - EnableTracking
- (void)enableTracking:(BOOL)enabled {
    self.isEnabled = enabled;
    dispatch_async(td_trackQueue, ^{
        [self.file archiveIsEnabled:self.isEnabled];
    });
}

- (void)optOutTracking {
    TDLogDebug(@"%@ optOutTracking...", self);
    [self doOptOutTracking];
}

- (void)optOutTrackingAndDeleteUser {
    TDLogDebug(@"%@ optOutTrackingAndDeleteUser...", self);
    TAUserEventDelete *deleteEvent = [[TAUserEventDelete alloc] init];
    deleteEvent.immediately = YES;
    [self asyncUserEventObject:deleteEvent properties:nil isH5:NO];
    
    [self doOptOutTracking];
}

- (void)optInTracking {
    TDLogDebug(@"%@ optInTracking...", self);
    self.isOptOut = NO;
    dispatch_async(td_trackQueue, ^{
        [self.file archiveOptOut:NO];
    });
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
        [self.dataQueue deleteAll:[self td_getMapInstanceTag]];
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

#pragma mark - LightInstance
- (ThinkingAnalyticsSDK *)createLightInstance {
    ThinkingAnalyticsSDK *lightInstance = [[LightThinkingAnalyticsSDK alloc] initWithAPPID:self.appid withServerURL:self.serverURL withConfig:self.config];
    lightInstance.identifyId = [TDDeviceInfo sharedManager].uniqueId;
    lightInstance.propertyPluginManager = self.propertyPluginManager;
    return lightInstance;
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
        self.accountId = [self.file unarchiveAccountID];
        [self.file archiveAccountID:self.accountId];
        [self.file deleteOldLoginId];
    }
}

- (void)deleteAll {
    dispatch_async(td_trackQueue, ^{
        @synchronized (TDSqliteDataQueue.class) {
            [self.dataQueue deleteAll:[self td_getMapInstanceTag]];
        }
    });
}

//MARK: - AppLifeCycle

- (void)appStateWillChangeNotification:(NSNotification *)notification {
    TAAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];
   
    if (newState == TAAppLifeCycleStateEnd) {
        [self stopFlushTimer];
    }
}


- (void)appStateDidChangeNotification:(NSNotification *)notification {
    TAAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];

    if (newState == TAAppLifeCycleStateStart) {
        [self startFlushTimer];

        // 更新时长统计
        NSTimeInterval systemUpTime = [TDDeviceInfo uptime];
        [self.trackTimer enterForegroundWithSystemUptime:systemUpTime];
    } else if (newState == TAAppLifeCycleStateEnd) {
        // 更新事件时长统计
        NSTimeInterval systemUpTime = [TDDeviceInfo uptime];
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
        
    } else if (newState == TAAppLifeCycleStateTerminate) {
        dispatch_sync(td_trackQueue, ^{});
        [self.eventTracker syncSendAllData];
    }
}

// MARK: -

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type {
    if ([self hasDisabled])
        return;
    
    [self.config setNetworkType:type];
}

+ (NSString *)getNetWorkStates {
    return [[TAReachability shareInstance] networkState];
}

//MARK: - Track

- (void)track:(NSString *)event {
    [self track:event properties:nil];
}

- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self track:event properties:propertiesDict time:nil timeZone:nil];
#pragma clang diagnostic pop
}

// deprecated
- (void)track:(NSString *)event properties:(NSDictionary *)propertiesDict time:(NSDate *)time {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self track:event properties:propertiesDict time:time timeZone:nil];
#pragma clang diagnostic pop
}

- (void)track:(NSString *)event properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    TATrackEvent *trackEvent = [[TATrackEvent alloc] initWithName:event];
    // TDLogDebug(@"##### track.systemUpTime: %lf", trackEvent.systemUpTime);
    [self configEventTimeValueWithEvent:trackEvent time:time timeZone:timeZone];
    [self handleTimeEvent:trackEvent];
    [self asyncTrackEventObject:trackEvent properties:properties isH5:NO];
}

- (void)trackWithEventModel:(TDEventModel *)eventModel {
    TATrackEvent *baseEvent = nil;
    if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
        TATrackFirstEvent *trackEvent = [[TATrackFirstEvent alloc] initWithName:eventModel.eventName];
        [self configEventTimeValueWithEvent:trackEvent time:eventModel.time timeZone:eventModel.timeZone];
        trackEvent.firstCheckId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
        TATrackUpdateEvent *trackEvent = [[TATrackUpdateEvent alloc] initWithName:eventModel.eventName];
        [self configEventTimeValueWithEvent:trackEvent time:eventModel.time timeZone:eventModel.timeZone];
        trackEvent.eventId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        TATrackOverwriteEvent *trackEvent = [[TATrackOverwriteEvent alloc] initWithName:eventModel.eventName];
        [self configEventTimeValueWithEvent:trackEvent time:eventModel.time timeZone:eventModel.timeZone];
        trackEvent.eventId = eventModel.extraID;
        baseEvent = trackEvent;
    } else if ([eventModel.eventType isEqualToString:TD_EVENT_TYPE_TRACK]) {
        TATrackEvent *trackEvent = [[TATrackEvent alloc] initWithName:eventModel.eventName];
        [self configEventTimeValueWithEvent:trackEvent time:eventModel.time timeZone:eventModel.timeZone];
        baseEvent = trackEvent;
    }
    [self asyncTrackEventObject:baseEvent properties:eventModel.properties isH5:NO];
}

- (void)trackFromAppExtensionWithAppGroupId:(NSString *)appGroupId {
    @try {
        if (appGroupId == nil || [appGroupId isEqualToString:@""]) {
            return;
        }
        
        TAAppExtensionAnalytic *analytic = [TAAppExtensionAnalytic analyticWithInstanceName:[self td_getMapInstanceTag] appGroupId:appGroupId];
        NSArray *eventArray = [analytic readAllEvents];
        if (eventArray) {
            for (NSDictionary *dict in eventArray) {
                NSString *eventName = dict[kTAAppExtensionEventName];
                NSDictionary *properties = dict[kTAAppExtensionEventProperties];
                NSDate *time = dict[kTAAppExtensionTime];
                // track event
                if ([time isKindOfClass:NSDate.class]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
                    [self track:eventName properties:properties time:time timeZone:nil];
#pragma clang diagnostic pop
                } else {
                    [self track:eventName properties:properties];
                }
            }
            [analytic deleteEvents];
        }
    } @catch (NSException *exception) {
        return;
    }
}

#pragma mark - Private

- (void)asyncTrackEventObject:(TATrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {

    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
    
    event.dynamicSuperProperties = [self.superProperty obtainDynamicSuperProperties];
    dispatch_async(td_trackQueue, ^{
        [self trackEvent:event properties:properties isH5:isH5];
    });
}

- (void)asyncUserEventObject:(TAUserEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {

    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
    
    [self configEventTimeValueWithEvent:event time:event.time timeZone:event.timeZone];
        
    dispatch_async(td_trackQueue, ^{
        [self trackUserEvent:event properties:properties isH5:NO];
    });
}

- (void)configEventTimeValueWithEvent:(TABaseEvent *)event time:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    event.timeZone = timeZone ?: self.config.defaultTimeZone;
    if (time) {
        event.time = time;
        if (timeZone == nil) {
            event.timeValueType = TAEventTimeValueTypeTimeOnly;
        } else {
            event.timeValueType = TAEventTimeValueTypeTimeAndZone;
        }
    } else {
        if (calibratedTime && !calibratedTime.stopCalibrate) {
            NSTimeInterval outTime = [TDDeviceInfo uptime] - calibratedTime.systemUptime;
            NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(calibratedTime.serverTime + outTime)];
            event.time = serverDate;
            event.timeValueType = TAEventTimeValueTypeTimeAndZone;
        }else{
            event.timeValueType = TAEventTimeValueTypeNone;
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

#pragma mark - User

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue {
    [self user_add:propertyName andPropertyValue:propertyValue withTime:nil];
}

- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate *)time {
    if (propertyName && propertyValue) {
        [self user_add:@{propertyName: propertyValue} withTime:time];
    }
}

- (void)user_add:(NSDictionary *)properties {
    [self user_add:properties withTime:nil];
}

- (void)user_add:(NSDictionary *)properties withTime:(NSDate *)time {
    TAUserEventAdd *event = [[TAUserEventAdd alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

- (void)user_setOnce:(NSDictionary *)properties {
    [self user_setOnce:properties withTime:nil];
}

- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate *)time {
    TAUserEventSetOnce *event = [[TAUserEventSetOnce alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

- (void)user_set:(NSDictionary *)properties {
    [self user_set:properties withTime:nil];
}

- (void)user_set:(NSDictionary *)properties withTime:(NSDate *)time {
    TAUserEventSet *event = [[TAUserEventSet alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

- (void)user_unset:(NSString *)propertyName {
    [self user_unset:propertyName withTime:nil];
}

- (void)user_unset:(NSString *)propertyName withTime:(NSDate *)time {
    if ([propertyName isKindOfClass:[NSString class]] && propertyName.length > 0) {
        NSDictionary *properties = @{propertyName: @0};
        TAUserEventUnset *event = [[TAUserEventUnset alloc] init];
        event.time = time;
        [self asyncUserEventObject:event properties:properties isH5:NO];
    }
}

- (void)user_delete {
    [self user_delete:nil];
}

- (void)user_delete:(NSDate *)time {
    TAUserEventDelete *event = [[TAUserEventDelete alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:nil isH5:NO];
}

- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties {
    [self user_append:properties withTime:nil];
}

- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate *)time {
    TAUserEventAppend *event = [[TAUserEventAppend alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    [self user_uniqAppend:properties withTime:nil];
}

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate *)time {
    TAUserEventUniqueAppend *event = [[TAUserEventUniqueAppend alloc] init];
    event.time = time;
    [self asyncUserEventObject:event properties:properties isH5:NO];
}

//MARK: -

+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion {
    if (libName.length > 0) {
        [TDDeviceInfo sharedManager].libName = libName;
    }
    if (libVersion.length > 0) {
        [TDDeviceInfo sharedManager].libVersion = libVersion;
    }
    [[TDDeviceInfo sharedManager] td_updateData];
}

- (NSString *)getAccountId {
    return _accountId;
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
    if ([self hasDisabled]) {
        return;
    }
    @synchronized (self.superProperty) {
        [self.superProperty registerDynamicSuperProperties:dynamicSuperProperties];
    }
}

- (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *,id> * _Nonnull (^)(void))dynamicSuperProperties {
    if ([self hasDisabled]) {
        return;
    }
    @synchronized (self.autoTrackSuperProperty) {
        [self.autoTrackSuperProperty registerAutoTrackDynamicProperties:dynamicSuperProperties];
    }
}

- (void)registerErrorCallback:(void (^)(NSInteger, NSString * _Nullable, NSString * _Nullable))errorCallback {
    self.errorCallback = errorCallback;
}

- (void)setSuperProperties:(NSDictionary *)properties {
    if ([self hasDisabled]) {
        return;
    }
    
    dispatch_async(td_trackQueue, ^{
        [self.superProperty registerSuperProperties:properties];
    });
}

- (void)unsetSuperProperty:(NSString *)propertyKey {
    if ([self hasDisabled]) {
        return;
    }
    dispatch_async(td_trackQueue, ^{
        [self.superProperty unregisterSuperProperty:propertyKey];
    });
}

- (void)clearSuperProperties {
    if ([self hasDisabled]) {
        return;
    }
    dispatch_async(td_trackQueue, ^{
        [self.superProperty clearSuperProperties];
    });
}

- (NSDictionary *)currentSuperProperties {
    return [self.superProperty currentSuperProperties];
}

- (TDPresetProperties *)getPresetProperties {
    NSMutableDictionary *presetDic = [NSMutableDictionary dictionary];

    NSDictionary *pluginProperties = [self.propertyPluginManager currentPropertiesForPluginClasses:@[TAPresetPropertyPlugin.class]];
    [presetDic addEntriesFromDictionary:pluginProperties];
    
    double offset = [[NSDate date] ta_timeZoneOffset:self.config.defaultTimeZone];
    [presetDic setObject:@(offset) forKey:@"#zone_offset"];
    
    if (![TDPresetProperties disableNetworkType]) {
        NSString *networkType = [self.class getNetWorkStates];
        [presetDic setObject:networkType?:@"" forKey:@"#network_type"];
    }
    
    // 将安装时间转为字符串
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
        @synchronized (instances) {
            [presetProperties updateValuesWithDictionary:presetDic];
        }
    }
    
    return presetProperties;
}

- (void)identify:(NSString *)distinctId {
    if (![distinctId isKindOfClass:[NSString class]] || distinctId.length == 0) {
        TDLogError(@"identify cannot null");
        return;
    }
    if ([self hasDisabled]) {
        return;
    }
    self.identifyId = distinctId;
    @synchronized (self.file) {
        [self.file archiveIdentifyId:distinctId];
    }
}

- (void)login:(NSString *)accountId {
    if (![accountId isKindOfClass:[NSString class]] || accountId.length == 0) {
        TDLogError(@"accountId invald", accountId);
        return;
    }

    if ([self hasDisabled]) {
        return;
    }
    self.accountId = accountId;
    @synchronized (self.file) {
        [self.file archiveAccountID:accountId];
    }
}

- (void)logout {
    if ([self hasDisabled]) {
        return;
    }
    self.accountId = nil;
    @synchronized (self.file) {
        [self.file archiveAccountID:nil];
    }
}

- (void)timeEvent:(NSString *)event {
    if ([self hasDisabled]) {
        return;
    }
    NSError *error = nil;
    [TAPropertyValidator validateEventOrPropertyName:event withError:&error];
    if (error) {
        return;
    }
    [self.trackTimer trackEvent:event withSystemUptime:[TDDeviceInfo uptime]];
}

+ (nullable NSString *)getLocalRegion {
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    return countryCode;
}

//MARK: -

- (void)configBaseEvent:(TABaseEvent *)event isH5:(BOOL)isH5 {
    
    if (event.timeZone == nil) {
        event.timeZone = self.config.defaultTimeZone;
    }
    
    if (event.timeValueType == TAEventTimeValueTypeNone && calibratedTime && !calibratedTime.stopCalibrate) {
        NSTimeInterval outTime = [TDDeviceInfo uptime] - calibratedTime.systemUptime;
        NSDate *serverDate = [NSDate dateWithTimeIntervalSince1970:(calibratedTime.serverTime + outTime)];
        event.time = serverDate;
    }
}

- (void)trackUserEvent:(TAUserEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    
    if (!event.isEnabled || event.isOptOut) {
        return;
    }
    
    if ([TDAppState shareInstance].relaunchInBackground && !self.config.trackRelaunchedInBackgroundEvents) {
        return;
    }
    
    [self configBaseEvent:event isH5:isH5];
    
    [event.properties addEntriesFromDictionary:[TAPropertyValidator validateProperties:properties validator:event]];
    
    NSDictionary *jsonObj = [event formatDateWithDict:event.jsonObject];
    
    [self.eventTracker track:jsonObj immediately:event.immediately saveOnly:event.isTrackPause];
}

- (void)trackEvent:(TATrackEvent *)event properties:(NSDictionary *)properties isH5:(BOOL)isH5 {
    
    if (!event.isEnabled || event.isOptOut) {
        return;
    }
    
    if ([TDAppState shareInstance].relaunchInBackground && !self.config.trackRelaunchedInBackgroundEvents && [event.eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT]) {
        return;
    }
    
    [self configBaseEvent:event isH5:isH5];
    
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
    
    NSDictionary *superProperties = [TAPropertyValidator validateProperties:self.superProperty.currentSuperProperties validator:event];
    
    NSDictionary *dynamicSuperProperties = [TAPropertyValidator validateProperties:event.dynamicSuperProperties validator:event];
    
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
        if ([event isKindOfClass:[TAAutoTrackEvent class]]) {
            TAAutoTrackEvent *autoEvent = (TAAutoTrackEvent *)event;
            
            NSDictionary *autoSuperProperties = [self.autoTrackSuperProperty currentSuperPropertiesWithEventName:event.eventName];
            
            autoSuperProperties = [TAPropertyValidator validateProperties:autoSuperProperties validator:autoEvent];
            
            [event.properties addEntriesFromDictionary:autoSuperProperties];
            
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *autoDynamicSuperProperties = [self.autoTrackSuperProperty obtainDynamicSuperPropertiesWithType:autoEvent.autoTrackEventType currentProperties:event.properties];
                autoDynamicSuperProperties = [TAPropertyValidator validateProperties:autoDynamicSuperProperties validator:autoEvent];
                [event.properties addEntriesFromDictionary:autoDynamicSuperProperties];

                dispatch_semaphore_signal(semaphore);
            });
            
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
        }
#endif
        properties = [TAPropertyValidator validateProperties:properties validator:event];
        [event.properties addEntriesFromDictionary:properties];

    }
    
    
    jsonObj = [event formatDateWithDict:jsonObj];

    [self.eventTracker track:jsonObj immediately:event.immediately saveOnly:event.isTrackPause];
}


- (void)flush {
    
    if ([self hasDisabled]) {
        return;
    }
    
    if (self.isTrackPause) {
        return;
    }
    [self.eventTracker flush];
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

#if TARGET_OS_IOS

//MARK: - Thired Party

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type {
    [self enableThirdPartySharing:type customMap:@{}];
}

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap {
    
#if TARGET_OS_IOS
    Class TARouterCls = NSClassFromString(@"TARouter");
    // com.thinkingdata://call.service/TAThirdPartyManager.TAThirdPartyProtocol/...?params={}(value url encode)
    NSURL *url = [NSURL URLWithString:@"com.thinkingdata://call.service.thinkingdata/TAThirdPartyManager.TAThirdPartyProtocol.enableThirdPartySharing:instance:property:/"];
    if (TARouterCls && [TARouterCls respondsToSelector:@selector(canOpenURL:)] && [TARouterCls respondsToSelector:@selector(openURL:withParams:)]) {
        if ([TARouterCls performSelector:@selector(canOpenURL:) withObject:url]) {
            [TARouterCls performSelector:@selector(openURL:withParams:) withObject:url withObject:@{@"TAThirdPartyManager":@{@1:[NSNumber numberWithInteger:type],@2:self,@3:customMap}}];
        }
    }
    
#endif
}

//MARK: - Auto Track

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    [self _enableAutoTrack:eventType properties:nil callback:nil];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    [self _enableAutoTrack:eventType properties:properties callback:nil];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback {
    [self _enableAutoTrack:eventType properties:nil callback:callback];
}

- (void)_enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback {
    [self.autoTrackSuperProperty registerSuperProperties:properties withType:eventType];
    [self.autoTrackSuperProperty registerDynamicSuperProperties:callback];
    
    [self _enableAutoTrack:eventType];
}

- (void)_enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    self.config.autoTrackEventType = eventType;
    
    
    [[TDAutoTrackManager sharedManager] trackWithAppid:[self td_getMapInstanceTag] withOption:eventType];
}

- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    
    if ([self hasDisabled]) {
        return;
    }
    
    if (properties == nil) {
        return;
    }
    
    @synchronized (self.autoTrackSuperProperty) {
        [self.autoTrackSuperProperty registerSuperProperties:[properties copy] withType:eventType];
    }
}

- (void)ignoreViewType:(Class)aClass {
    if ([self hasDisabled]) {
        return;
    }
    @synchronized (self.ignoredViewTypeList) {
        [self.ignoredViewTypeList addObject:aClass];
    }
}

- (BOOL)isViewTypeIgnored:(Class)aClass {
    return [_ignoredViewTypeList containsObject:aClass];
}

- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType {
    return !(_config.autoTrackEventType & eventType);
}

- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers {
    if ([self hasDisabled]) {
        return;
    }
    
    if (controllers == nil || controllers.count == 0) {
        return;
    }
    
    @synchronized (self.ignoredViewControllers) {
        [self.ignoredViewControllers addObjectsFromArray:controllers];
    }
}

- (void)autoTrackWithEvent:(TAAutoTrackEvent *)event properties:(NSDictionary *)properties {
    TDLogDebug(@"##### autoTrackWithEvent: %@", event.eventName);
    [self configEventTimeValueWithEvent:event time:nil timeZone:nil];
    [self handleTimeEvent:event];
    [self asyncAutoTrackEventObject:event properties:properties];
}

/// Add event to event queue
- (void)asyncAutoTrackEventObject:(TAAutoTrackEvent *)event properties:(NSDictionary *)properties {
    
    event.isEnabled = self.isEnabled;
    event.trackPause = self.isTrackPause;
    event.isOptOut = self.isOptOut;
    event.accountId = self.accountId;
    event.distinctId = self.identifyId;
    
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
        [self trackEvent:event properties:properties isH5:NO];
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

#endif

// MARK: - H5 tracking

- (void)clickFromH5:(NSString *)data {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return;
    }
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
                if (extraID) {
                    type = TD_EVENT_TYPE_TRACK_FIRST;
                }
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
                dispatch_async(td_trackQueue, ^{
                    [instance h5track:event_name
                              extraID:extraID
                           properties:dic
                                 type:type
                                 time:time];
                });
            } else {
                dispatch_async(td_trackQueue, ^{
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

- (void)h5track:(NSString *)eventName
        extraID:(NSString *)extraID
     properties:(NSDictionary *)propertieDict
           type:(NSString *)type
           time:(NSString *)time {
    
    if ([ThinkingAnalyticsSDK isTrackEvent:type]) {
        TATrackEvent *event = nil;
        if ([type isEqualToString:TD_EVENT_TYPE_TRACK]) {
            TATrackEvent *trackEvent = [[TATrackEvent alloc] initWithName:eventName];
            event = trackEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            TATrackFirstEvent *firstEvent = [[TATrackFirstEvent alloc] initWithName:eventName];
            firstEvent.firstCheckId = extraID;
            event = firstEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
            TATrackUpdateEvent *updateEvent = [[TATrackUpdateEvent alloc] initWithName:eventName];
            updateEvent.eventId = extraID;
            event = updateEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
            TATrackOverwriteEvent *overwriteEvent = [[TATrackOverwriteEvent alloc] initWithName:eventName];
            overwriteEvent.eventId = extraID;
            event = overwriteEvent;
        }
        event.h5TimeString = time;
        if ([propertieDict objectForKey:@"#zone_offset"]) {
            event.h5ZoneOffSet = [propertieDict objectForKey:@"#zone_offset"];
        }
        [self asyncTrackEventObject:event properties:propertieDict isH5:YES];
    } else {
        TAUserEvent *event = [[TAUserEvent alloc] initWithType:[TABaseEvent typeWithTypeString:type]];
        [self asyncUserEventObject:event properties:propertieDict isH5:YES];
    }
}

- (double)getTimezoneOffset:(NSDate *)date timeZone:(NSTimeZone *)timeZone {
    return [date ta_timeZoneOffset:timeZone];
}

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

#pragma mark - Calibrate time

+ (void)calibrateTime:(NSTimeInterval)timestamp {
    calibratedTime = [TDCalibratedTime sharedInstance];
    [[TDCalibratedTime sharedInstance] recalibrationWithTimeInterval:timestamp/1000.];
    //NSLog(@"After version 2.8.4, the external time calibration API is discarded, and the SDK will automatically calibrate");
}

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer {
    if ([ntpServer isKindOfClass:[NSString class]] && ntpServer.length > 0) {
        calibratedTime = [TDCalibratedTimeWithNTP sharedInstance];
        [[TDCalibratedTimeWithNTP sharedInstance] recalibrationWithNtps:@[ntpServer]];
    }
    //NSLog(@"After version 2.8.4, the external time calibration API is discarded, and the SDK will automatically calibrate");
}

// for UNITY
- (NSString *)getTimeString:(NSDate *)date {
    return [date ta_formatWithTimeZone:self.config.defaultTimeZone formatString:kDefaultTimeFormat];
}

//MARK: - Private

- (void)handleTimeEvent:(TATrackEvent *)trackEvent {
    
    BOOL isTrackDuration = [self.trackTimer isExistEvent:trackEvent.eventName];
    BOOL isEndEvent = [trackEvent.eventName isEqualToString:TD_APP_END_EVENT];
    BOOL isStartEvent = [trackEvent.eventName isEqualToString:TD_APP_START_EVENT];
    BOOL isStateInit = [TAAppLifeCycle shareInstance].state == TAAppLifeCycleStateInit;
    
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
        
        TDLogDebug(@"#####eventName: %@, foregroundDuration: %d", trackEvent.eventName, trackEvent.foregroundDuration);
        TDLogDebug(@"#####eventName: %@, backgroundDuration: %d", trackEvent.eventName, trackEvent.backgroundDuration);
        
        [self.trackTimer removeEvent:trackEvent.eventName];
    } else {
         
        if (trackEvent.eventName == TD_APP_END_EVENT) {
            return;
        }
    }
}

+ (NSMutableDictionary *)_getAllInstances {
    return instances;
}

+ (void)_clearCalibratedTime {
    calibratedTime = nil;
}

- (BOOL)isValidName:(NSString *)name isAutoTrack:(BOOL)isAutoTrack {
    return YES;
}

- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *_Nullable)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents {
    return YES;
}

- (void)flushImmediately:(NSDictionary *)dataDic {

}

+ (dispatch_queue_t)td_networkQueue {
    return [TAEventTracker td_networkQueue];
}

- (NSInteger)saveEventsData:(NSDictionary *)data {
    return [self.eventTracker saveEventsData:data];
}

// MARK: - getter & setter

- (TAAutoTrackSuperProperty *)autoTrackSuperProperty {
    if (!_autoTrackSuperProperty) {
        _autoTrackSuperProperty = [[TAAutoTrackSuperProperty alloc] init];
    }
    return _autoTrackSuperProperty;
}

@end
