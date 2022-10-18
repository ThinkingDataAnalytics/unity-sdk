#import "ThinkingAnalyticsSDKPrivate.h"

#import "TDAutoTrackManager.h"
#import "TDCalibratedTimeWithNTP.h"
#import "TDConfig.h"
#import "TDPublicConfig.h"
#import "TDFile.h"
#import "TANetwork.h"
#import "TDCheck.h"
#import "TDJSONUtil.h"
#import "TDToastView.h"
#import "NSString+TDString.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDRuntime.h"
#import "TDAppState.h"
#import "TDEncrypt.h"
#import "TDEventRecord.h"
#import "TDThirdPartyProtocol.h"
#import "TAAppExtensionAnalytic.h"
#import "TAReachability.h"

#if !__has_feature(objc_arc)
#error The ThinkingSDK library must be compiled with ARC enabled
#endif

#define td_force_inline __inline__ __attribute__((always_inline))

// 是否是自动采集事件
static td_force_inline BOOL _isAutoTrackEvent(NSString *eventName) {
    if ([eventName isEqualToString:TD_APP_START_EVENT] ||
        [eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT] ||
        [eventName isEqualToString:TD_APP_END_EVENT] ||
        [eventName isEqualToString:TD_APP_VIEW_EVENT] ||
        [eventName isEqualToString:TD_APP_CLICK_EVENT] ||
        [eventName isEqualToString:TD_APP_CRASH_EVENT] ||
        [eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
        return YES;
    }
    return NO;
}

// 根据eventName返回自动采集类型
static td_force_inline ThinkingAnalyticsAutoTrackEventType _getAutoTrackEventType(NSString *eventName) {
    if ([eventName isEqualToString:TD_APP_START_EVENT]) {
        return ThinkingAnalyticsEventTypeAppStart;
    } else if ([eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT]) {
        return ThinkingAnalyticsEventTypeAppStart;
    } else if ([eventName isEqualToString:TD_APP_END_EVENT]) {
        return ThinkingAnalyticsEventTypeAppEnd;
    } else if ([eventName isEqualToString:TD_APP_VIEW_EVENT]) {
        return ThinkingAnalyticsEventTypeAppViewScreen;
    } else if ([eventName isEqualToString:TD_APP_CLICK_EVENT]) {
        return ThinkingAnalyticsEventTypeAppClick;
    } else if ([eventName isEqualToString:TD_APP_CRASH_EVENT]) {
        return ThinkingAnalyticsEventTypeAppViewCrash;
    } else if ([eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
        return ThinkingAnalyticsEventTypeAppInstall;
    } else {
        return ThinkingAnalyticsEventTypeNone;
    }
}

@interface TDPresetProperties (ThinkingAnalytics)

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (void)updateValuesWithDictionary:(NSDictionary *)dict;

@end

@interface ThinkingAnalyticsSDK ()
@property (atomic, strong)   TANetwork *network;
@property (atomic, strong)   TDAutoTrackManager *autoTrackManager;
@property (nonatomic, strong)   TDColdStartTracker *startInitTracker;// 冷启动事件Tracker
@property (nonatomic, strong)   TDInstallTracker *installTracker;// install事件Tracker

@property (strong,nonatomic) TDFile *file;
@property (strong,nonatomic) TDEncryptManager *encryptManager;
@property (strong,nonatomic) id<TDThirdPartyProtocol> thirdPartyManager;

@end

@implementation ThinkingAnalyticsSDK

static NSMutableDictionary *instances;
static NSString *defaultProjectAppid;
static TDCalibratedTime *calibratedTime;
static dispatch_queue_t td_trackQueue; // track操作、操作数据库等在td_trackQueue中进行
static dispatch_queue_t td_networkQueue;// 网络请求在td_networkQueue中进行

static double td_enterBackgroundTime = 0; //进入后台时间
static double td_enterDidBecomeActiveTime = 0;// 进入前台时间

+ (NSMutableDictionary *)_getAllInstances {
    return instances;
}

+ (void)_clearCalibratedTime {
    calibratedTime = nil;
}

+ (nullable ThinkingAnalyticsSDK *)sharedInstance {
    if (instances.count == 0) {
        TDLogError(@"sharedInstance called before creating a Thinking instance");
        return nil;
    }
    return instances[defaultProjectAppid];
}

+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid {
    appid = appid.td_trim;// 去除空格
    if (instances[appid]) {
        return instances[appid];
    } else {
        TDLogError(@"sharedInstanceWithAppid called before creating a Thinking instance");
        return nil;
    }
}

+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(TDConfig *)config {
    appId = appId.td_trim; // 去除空格
    
    // name存在，先从内存取，取不到再初始化
    NSString *name = config.name;
    if (name && [name isKindOfClass:[NSString class]] && name.length) {
        if (instances[name]) {
            return instances[name];
        } else {
            return [[self alloc] initWithAppkey:appId withServerURL:url withConfig:config];
        }
    }
    
    // name不存在，(原逻辑)appid存在，先从内存取，取不到再初始化
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
        NSString *networkLabel = [queuelabel stringByAppendingString:@".network"];
        td_networkQueue = dispatch_queue_create([networkLabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
}

+ (dispatch_queue_t)td_trackQueue {
    return td_trackQueue;
}

+ (dispatch_queue_t)td_networkQueue {
    return td_networkQueue;
}

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config {
    if (self = [self init]) {
        serverURL = [self checkServerURL:serverURL];
        _appid = appid;
        _isEnabled = YES;
        _serverURL = serverURL;
        _config = [config copy];
        _config.configureURL = serverURL;
        
        self.trackTimer = [[TATrackTimer alloc] init];
        
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
        
        _network = [[TANetwork alloc] init];
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
        
        self.file = [[TDFile alloc] initWithAppid:[self td_getMapInstanceTag]];
        // 恢复配置
        [self retrievePersistedData];
        
        // config获取intanceName
        NSString *instanceName = [self td_getMapInstanceTag];
        
        // 加载加密插件
        if (_config.enableEncrypt) {
            self.encryptManager = [[TDEncryptManager alloc] initWithConfig:config];
        }
        
        _config.getInstanceName = ^NSString * _Nonnull{
            return instanceName;
        };
        
        //次序不能调整，异步获取加密配置
        __weak __typeof(self)weakSelf = self;
        [_config updateConfig:^(NSDictionary * _Nonnull secretKey) {
            if (weakSelf.config.enableEncrypt && secretKey) {
                [weakSelf.encryptManager handleEncryptWithConfig:secretKey];
            }
        }];
        
        self.trackTimer = [[TATrackTimer alloc] init];
        
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
        NSString *keyAutoTrackPattern = @"^([a-zA-Z][a-zA-Z\\d_]{0,49}|\\#(resume_from_background|app_crashed_reason|screen_name|referrer|title|url|element_id|element_type|element_content|element_position|background_duration|start_reason))$";
        self.regexAutoTrackKey = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", keyAutoTrackPattern];
        
        self.dataQueue = [TDSqliteDataQueue sharedInstanceWithAppid:[self td_getMapInstanceTag]];
        if (self.dataQueue == nil) {
            TDLogError(@"SqliteException: init SqliteDataQueue failed");
        }
                
        [[TAReachability shareInstance] startMonitoring];
        
        self.autoTrackManager = [TDAutoTrackManager sharedManager];
        
        _network = [[TANetwork alloc] init];
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
        
        instances[[self td_getMapInstanceTag]] = self;
        
        if ([self ableMapInstanceTag]) {
            TDLogInfo(@"Thinking Analytics SDK %@ instance initialized successfully with mode: %@, Instance Name: %@,  APP ID: %@, server url: %@, device ID: %@", [TDDeviceInfo libVersion], [self modeEnumToString:config.debugMode], _config.name, appid, serverURL, [self getDeviceId]);
        } else {
            TDLogInfo(@"Thinking Analytics SDK %@ instance initialized successfully with mode: %@, APP ID: %@, server url: %@, device ID: %@", [TDDeviceInfo libVersion], [self modeEnumToString:config.debugMode], appid, serverURL, [self getDeviceId]);
        }
        
    }
    return self;
}

- (BOOL)ableMapInstanceTag {
    return _config.name && [_config.name isKindOfClass:[NSString class]] && _config.name.length;
}

- (NSString *)td_getMapInstanceTag {
    if ([self ableMapInstanceTag]) {
        return self.config.name;
    } else {
        return self.appid;
    }
}

- (void)launchedIntoBackground:(NSDictionary *)launchOptions {
    td_dispatch_main_sync_safe(^{
        if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            if ([TDAppState sharedApplication]) {
                UIApplicationState applicationState = [TDAppState sharedApplication].applicationState;
                if (applicationState == UIApplicationStateBackground) {
                    self->_relaunchInBackGround = YES;
                }
            }
        }
    });
}

- (NSString *)description {
    if ([self ableMapInstanceTag]) {
        return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - instanceName: %@ appid: %@ serverUrl: %@>", (void *)self, _config.name, self.appid, self.serverURL];
    } else {
        return [NSString stringWithFormat:@"<ThinkingAnalyticsSDK: %p - appid: %@ serverUrl: %@>", (void *)self, self.appid, self.serverURL];
    }
}

+ (UIApplication *)sharedUIApplication {
    if ([[UIApplication class] respondsToSelector:@selector(sharedApplication)]) {
        return [[UIApplication class] performSelector:@selector(sharedApplication)];
    }
    return nil;
}

/// 数据上报状态
/// @param status 数据上报状态
- (void)setTrackStatus: (TATrackStatus)status {
    switch (status) {
            // 暂停SDK上报
        case TATrackStatusPause: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusStop...", self);
            [self enableTracking:NO];
            break;
        }
            // 停止SDK上报并清除缓存
        case TATrackStatusStop: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusStopAndClean...", self);
            [self doOptOutTracking];
            break;
        }
            // 可以入库 暂停发送数据
        case TATrackStatusSaveOnly: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusPausePost...", self);
            self.trackPause = YES;
            dispatch_async(td_trackQueue, ^{
                [self.file archiveTrackPause:YES];
            });
            break;
        }
            // 恢复所有状态
        case TATrackStatusNormal: {
            TDLogDebug(@"%@ switchTrackStatus: TATrackStatusRestartAll...", self);
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
        [self.trackTimer clear];
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
    
    dispatch_async(td_trackQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:[self td_getMapInstanceTag]];
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
    dispatch_async(td_trackQueue, ^{
        [self.file archiveOptOut:NO];
    });
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
    self.trackPause = [self.file unarchiveTrackPause];
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
        // 加密数据
        if (_config.enableEncrypt) {
            NSDictionary *dic = [self.encryptManager encryptJSONObject:event];
            count = [self.dataQueue addObject:dic withAppid:[self td_getMapInstanceTag]];
        } else {
            count = [self.dataQueue addObject:event withAppid:[self td_getMapInstanceTag]];
        }
    }
    return count;
}

- (void)deleteAll {
    dispatch_async(td_trackQueue, ^{
        @synchronized (instances) {
            [self.dataQueue deleteAll:[self td_getMapInstanceTag]];
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

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    TDLogDebug(@"%@ application will enter foreground", self);
    
    if ([TDAppState sharedApplication] && [TDAppState sharedApplication].applicationState == UIApplicationStateBackground) {
        _relaunchInBackGround = NO;
        _appRelaunched = YES;
        dispatch_async(td_trackQueue, ^{
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
    td_enterBackgroundTime = NSProcessInfo.processInfo.systemUptime;// 记录进后台时间
    
    __block UIBackgroundTaskIdentifier backgroundTask = [[ThinkingAnalyticsSDK sharedUIApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:backgroundTask];
        self.taskId = UIBackgroundTaskInvalid;
    }];
    self.taskId = backgroundTask;
    
    dispatch_group_t bgGroup = dispatch_group_create();
    
    dispatch_group_enter(bgGroup);
    dispatch_async(td_trackQueue, ^{
        // 更新事件时长统计
        [self.trackTimer enterBackground];
        dispatch_group_leave(bgGroup);
    });
    
    // 采集 end 事件
    if (self.config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        // 记录当前界面的名字
        NSString *screenName = screenName = NSStringFromClass([[TDAutoTrackManager topPresentedViewController] class]);
        [self autotrack:TD_APP_END_EVENT properties:@{TD_EVENT_PROPERTY_SCREEN_NAME: screenName ?: @""} withTime:nil];
    }
    
    dispatch_group_enter(bgGroup);
    [self _asyncWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_group_leave(bgGroup);
        });
    }];
    
    dispatch_group_notify(bgGroup, dispatch_get_main_queue(), ^{
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[ThinkingAnalyticsSDK sharedUIApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 保证在app杀掉的时候，同步执行完队列内的任务
    dispatch_sync(td_trackQueue, ^{});
    dispatch_sync(td_networkQueue, ^{});
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application will resign active", self);
    _applicationWillResignActive = YES;
    [self stopFlushTimer];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogDebug(@"%@ application did become active", self);
    //NSLog(@" [THINKING] application did become active");
    [self startFlushTimer];
    
    // 表示app仍在前台，只是暂时失活，此时不需要记录app_start事件。例如：进入后台任务管理模式；下拉通知栏遮挡app；调用控制中心遮挡app等
    if (_applicationWillResignActive) {
        _applicationWillResignActive = NO;
        return;
    }
    _applicationWillResignActive = NO;
    
    // 记录进入前台时间
    td_enterDidBecomeActiveTime = NSProcessInfo.processInfo.systemUptime;
    
    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    dispatch_async(td_trackQueue, ^{
        [self.trackTimer enterForeground];
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (self.appRelaunched) {
            if (self.config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart) {
                [self autotrack:TD_APP_START_EVENT properties:[self getStartEventPresetProperties:NO] withTime:nil];
            }
            if (self.config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
                [self timeEvent:TD_APP_END_EVENT];
            }
        }
    });
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

+ (NSString *)getNetWorkStates {
    return [[TAReachability shareInstance] networkState];
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


- (void)enableThirdPartySharing:(TAThirdPartyShareType)type {
    [self enableThirdPartySharing:type customMap:@{}];
}

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap {
    if (!self.thirdPartyManager) {
        Class cls = NSClassFromString(@"TAThirdPartyManager");
        if (!cls) {
    //        TDLog(@"请安装三方扩展插件");
            return;
        }
        self.thirdPartyManager = [[cls alloc] init];
    }
    
    [self.thirdPartyManager enableThirdPartySharing:type instance:self property:customMap];
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
    
    NSMutableDictionary<NSString *, id> *properties = [NSMutableDictionary dictionary];
    if (propertieDict && [propertieDict isKindOfClass:[NSDictionary class]]) {
        [properties addEntriesFromDictionary:propertieDict];
    }
    
    // 获取自定义属性，属性优先级最高
    if (self.autoCustomProperty.allKeys.count) {
        NSDictionary *autoEventProperty = [self.autoCustomProperty objectForKey:event];
        if (autoEventProperty && [autoEventProperty isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:autoEventProperty];
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    properties = [self processParameters:properties withType:TD_EVENT_TYPE_TRACK withEventName:event withAutoTrack:YES withH5:NO];
#pragma clang diagnostic pop
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

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties {
    [self user_uniqAppend:properties withTime:nil];
}

- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate *)time {
    [self track:nil withProperties:properties withType:TD_EVENT_TYPE_USER_UNIQ_APPEND withTime:time];
}

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
    
    dispatch_async(td_trackQueue, ^{
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
    dispatch_async(td_trackQueue, ^{
        [self.file archiveSuperProperties:self.superProperty];
    });
}

- (void)clearSuperProperties {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.superProperty) {
        self.superProperty = @{};
    }
    
    dispatch_async(td_trackQueue, ^{
        [self.file archiveSuperProperties:self.superProperty];
    });
}

- (NSDictionary *)currentSuperProperties {
    if (self.superProperty) {
        return [self.superProperty copy];
    } else {
        return @{};
    }
}

- (TDPresetProperties *)getPresetProperties {
    
    NSDictionary *autoDic = [[TDDeviceInfo sharedManager] td_collectProperties];
    NSMutableDictionary *presetDic = [NSMutableDictionary new];
    
    if (![TDPresetProperties disableBundleId]) {
        NSString *bundleId = [TDDeviceInfo bundleId];
        [presetDic setObject:bundleId?:@"" forKey:@"#bundle_id"];
    }
    if (![TDPresetProperties disableCarrier]) {
        [presetDic setObject:autoDic[@"#carrier"]?:@"" forKey:@"#carrier"];
    }
    if (![TDPresetProperties disableDeviceId]) {
        [presetDic setObject:autoDic[@"#device_id"]?:@"" forKey:@"#device_id"];
    }
    if (![TDPresetProperties disableDeviceModel]) {
        [presetDic setObject:autoDic[@"#device_model"]?:@"" forKey:@"#device_model"];
    }
    if (![TDPresetProperties disableManufacturer]) {
        [presetDic setObject:autoDic[@"#manufacturer"]?:@"" forKey:@"#manufacturer"];
    }
    if (![TDPresetProperties disableNetworkType]) {
        NSString *networkType = [self.class getNetWorkStates];
        [presetDic setObject:networkType?:@"" forKey:@"#network_type"];
    }
    if (![TDPresetProperties disableOs]) {
        [presetDic setObject:autoDic[@"#os"]?:@"" forKey:@"#os"];
    }
    if (![TDPresetProperties disableOsVersion]) {
        [presetDic setObject:autoDic[@"#os_version"]?:@"" forKey:@"#os_version"];
    }
    if (![TDPresetProperties disableScreenHeight]) {
        [presetDic setObject:autoDic[@"#screen_height"]?:@(0) forKey:@"#screen_height"];
    }
    if (![TDPresetProperties disableScreenWidth]) {
        [presetDic setObject:autoDic[@"#screen_width"]?:@(0) forKey:@"#screen_width"];
    }
    if (![TDPresetProperties disableSystemLanguage]) {
        [presetDic setObject:autoDic[@"#system_language"]?:@"" forKey:@"#system_language"];
    }
    if (![TDPresetProperties disableZoneOffset]) {
        double offset = [self getTimezoneOffset:[NSDate date] timeZone:_config.defaultTimeZone];
        [presetDic setObject:@(offset)?:@(0) forKey:@"#zone_offset"];
    }
    if (![TDPresetProperties disableAppVersion]) {
        [presetDic setObject:[TDDeviceInfo sharedManager].appVersion forKey:@"#app_version"];
    }
    if (![TDPresetProperties disableInstallTime]) {
        [presetDic setObject:[_timeFormatter stringFromDate:[TDDeviceInfo td_getInstallTime]] forKey:@"#install_time"];
    }
    if (![TDPresetProperties disableRAM]) {
        [presetDic setObject:autoDic[@"#ram"]?:@"" forKey:@"#ram"];
    }
    if (![TDPresetProperties disableDisk]) {
        [presetDic setObject:autoDic[@"#disk"]?:@"" forKey:@"#disk"];
    }
    if (![TDPresetProperties disableSimulator]) {
        [presetDic setObject:autoDic[@"#simulator"]?:[NSNumber numberWithBool:YES] forKey:@"#simulator"];
    }
    if (![TDPresetProperties disableFPS]) {
        [presetDic setObject:autoDic[@"#fps"]?:@(0) forKey:@"#fps"];
    }
  
    static TDPresetProperties *presetProperties = nil;
    if (presetProperties == nil) {
        presetProperties = [[TDPresetProperties alloc] initWithDictionary:presetDic];
    }
    else {
        @synchronized (instances) {
            [presetProperties updateValuesWithDictionary:presetDic];
        }
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
    dispatch_async(td_trackQueue, ^{
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
    
    dispatch_async(td_trackQueue, ^{
        [self.file archiveAccountID:accountId];
    });
}

- (void)logout {
    if ([self hasDisabled])
        return;
    
    @synchronized (self.accountId) {
        self.accountId = nil;
    }
    dispatch_async(td_trackQueue, ^{
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
    
    @synchronized (self.trackTimer) {
        [self.trackTimer trackEvent:event];
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

// 检查properties的key和value
// 要求：key是字符串类型、key要满足正则要求；value要求是字符串或数字或时间或数组类型
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
            ![obj isKindOfClass:[NSArray class]] &&
            ![obj isKindOfClass:[NSDictionary class]]) {
            NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSString, NSNumber, NSDate, NSDictionary or NSArray. got: %@ %@. ", [obj class], obj];
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

- (void) tdInternalTrack:(TDEventModel *)eventData
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

    double offset = 0;
    if (eventData.timeValueType == TDTimeValueTypeNone) {
        NSDate *currentDate = [NSDate date];
        // 兼容install事件和start事件一样的情况
        if ([eventData.eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
            currentDate = [currentDate dateByAddingTimeInterval:-1];
        }
        timeString = [_timeFormatter stringFromDate:currentDate];
        
        offset = [self getTimezoneOffset:[NSDate date] timeZone:_config.defaultTimeZone];
    } else {
        timeString = eventData.timeString;
        offset = eventData.zoneOffset;
    }
    
    
    
    if ([ThinkingAnalyticsSDK isTrackEvent:eventData.eventType]) {
        if (![TDPresetProperties disableAppVersion]) {
            properties[@"#app_version"] = [TDDeviceInfo sharedManager].appVersion;
        }
        if (![TDPresetProperties disableBundleId]) {
            properties[@"#bundle_id"] = [TDDeviceInfo bundleId];
        }
        
        if (_relaunchInBackGround) {
            properties[@"#relaunched_in_background"] = @YES;
        }
        if (eventData.timeValueType != TDTimeValueTypeTimeOnly) {
            if (![TDPresetProperties disableZoneOffset]) {
                properties[@"#zone_offset"] = @(offset);
            }
        }
        @synchronized ([TDDeviceInfo sharedManager]) {
            [properties addEntriesFromDictionary:[[TDDeviceInfo sharedManager] getAutomaticData]];
            if (![TDPresetProperties disableInstallTime]) {
                [properties setObject:[_timeFormatter stringFromDate:[TDDeviceInfo td_getInstallTime]] forKey:@"#install_time"];// 安装时间
            }
        }
    }
    
    [properties addEntriesFromDictionary:propertiesDict];
    
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    
    if (properties) {
        dataDic[@"properties"] = [NSDictionary dictionaryWithDictionary:properties];
    }
    
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
    
    @synchronized (self.trackTimer) {
        [self _handleAutoTrackBack:eventData.eventName dataDic:dataDic];
    }
    
    // 触发事件时的时间点标记。在当前线程记录，因为在trackQueue中重新捕捉，会有延后问题。
    NSTimeInterval systemUptime = NSProcessInfo.processInfo.systemUptime;

    if (eventData.persist) {
        dispatch_async(td_trackQueue, ^{
            NSMutableDictionary *updateProperties = [dataDic[@"properties"] mutableCopy];

            if ([ThinkingAnalyticsSDK isTrackEvent:eventData.eventType]) {
                // 增加duration属性
                BOOL isTrackDuration = [self.trackTimer isExistEvent:eventData.eventName];
                if (isTrackDuration) {
                    // app 是否在前台
                    BOOL isActive = ![TDAppState isStateBackground];
                    
                    // 计算累计前台时长
                    NSTimeInterval foregroundDuration = [self.trackTimer foregroundDurationOfEvent:eventData.eventName isActive:isActive systemUptime:systemUptime];
                    
                    if (foregroundDuration > 0) {
                        updateProperties[@"#duration"] = @([[NSString stringWithFormat:@"%.3f", foregroundDuration] doubleValue]);
                    }
                    
                    // 计算累计后台时长
                    if (eventData.eventName != TD_APP_END_EVENT) {
                        NSTimeInterval backgroundDuration = [self.trackTimer backgroundDurationOfEvent:eventData.eventName isActive:isActive systemUptime:systemUptime];
                        
                        if (backgroundDuration > 0) {
                            updateProperties[TD_BACKGROUND_DURATION] = @([[NSString stringWithFormat:@"%.3f", backgroundDuration] doubleValue]);
                        }
                    }
                    
                    // 计算时长后，删除当前事件的记录
                    [self.trackTimer removeEvent:eventData.eventName];
                } else {
                    // 没有事件时长的 TD_APP_END_EVENT 事件，判定为重复的无效 end 事件。（系统的生命周期方法可能回调用多次，会造成重复上报）
                    if (eventData.eventName == TD_APP_END_EVENT) {
                        return;
                    }
                }
                
                updateProperties[@"#network_type"] = [[self class] getNetWorkStates];
            }
            
            // 过滤预置属性
            [TDPresetProperties handleFilterDisPresetProperties:updateProperties];
            dataDic[@"properties"] = updateProperties;
            
            NSDictionary *finalDic = dataDic;
            if (eventData.timeValueType == TDTimeValueTypeNone && calibratedTime && !calibratedTime.stopCalibrate) {
                finalDic = [self calibratedTime:dataDic withDate:nowDate withSystemDate:systemUptime withEventData:eventData];
            }
            NSInteger count = 0;
            if (self.config.debugMode == ThinkingAnalyticsDebugOnly || self.config.debugMode == ThinkingAnalyticsDebug) {
                TDLogDebug(@"queueing debug data:%@", finalDic);
                [self flushDebugEvent:finalDic];
                @synchronized (instances) {
                    count = [self.dataQueue sqliteCountForAppid:[self td_getMapInstanceTag]];
                }
            } else {
                TDLogDebug(@"queueing data:%@", finalDic);
                count = [self saveEventsData:finalDic];
            }
            if (count >= [self.config.uploadSize integerValue]) {
                TDLogDebug(@"flush action, count: %ld, uploadSize: %d",count, [self.config.uploadSize integerValue]);
                [self flush];
            }
        });
    } else {
        TDLogDebug(@"queueing data flush immediately:%@", dataDic);
        dispatch_async(td_trackQueue, ^{
            [self flushImmediately:dataDic];
        });
    }
}

/**
 处理自动采集事件回调
 
 该方法只能在serialQueue中执行
 */
- (void)_handleAutoTrackBack:(NSString *)eventName dataDic:(NSMutableDictionary *)dataDic
{
    // 判断事件是否是自动采集事件
    if (!dataDic || ![dataDic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    // 不是自动采集事件
    if (!_isAutoTrackEvent(eventName)) {
        return;
    }
    
    ThinkingAnalyticsAutoTrackEventType autoTrackEventType = _getAutoTrackEventType(eventName);
    if (_autoTrackCallback &&
        _config.autoTrackEventType != ThinkingAnalyticsEventTypeNone &&
        ((_config.autoTrackEventType & autoTrackEventType) == autoTrackEventType)) {
        
        NSDictionary *addProperty = _autoTrackCallback(autoTrackEventType, dataDic[@"properties"]);
        addProperty = [addProperty copy];
        
        // 检查外部增加的Property
        if (addProperty &&
            [addProperty isKindOfClass:[NSDictionary class]] &&
            [self checkEventProperties:addProperty withEventType:nil haveAutoTrackEvents:NO]) {
            
            // 外部有值才会去增加
            if (addProperty.allKeys.count > 0) {
                NSMutableDictionary *updateProperties = [dataDic[@"properties"] mutableCopy];
                [updateProperties addEntriesFromDictionary:[addProperty copy]];
                dataDic[@"properties"] = updateProperties;
            }
           
        } else {
            if ([TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone) {
                TDLogError(@"%@ autoTrackCallback Properties error.", addProperty);
            }
        }
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
        if (![TDPresetProperties disableZoneOffset]) {
            properties[@"#zone_offset"] = @(offset);
        }
    }
    calibratedData[@"properties"] = properties;
    return calibratedData;
}

- (void)flushImmediately:(NSDictionary *)dataDic {
    dispatch_async(td_trackQueue, ^{
        dispatch_async(td_networkQueue, ^{
            [self.network flushEvents:@[dataDic]];
        });
    });
    
}

// 整理参数列表property
// 属性优先级：如果属性名称一样，其优先级为 外部属性 > 动态公共属性 > 静态公共属性
// 检查eventName、property是否有效(如果是H5的场景不用check)
- (NSDictionary<NSString *,id> *)processParameters:(NSDictionary<NSString *,id> *)propertiesDict withType:(NSString *)eventType withEventName:(NSString *)eventName withAutoTrack:(BOOL)autotrack withH5:(BOOL)isH5 {
    
    // 对外部属性property进行copy
    NSDictionary *propertiesDictCopy;
    if (propertiesDict) {
        if ([propertiesDict isKindOfClass:[NSDictionary class]]) {
            propertiesDictCopy = [propertiesDict copy];
        } else {
            // 检查属性的正确性
            TDLogDebug(@"The property must be NSDictionary. got: %@ %@", [propertiesDict class], propertiesDict);
        }
    }
    
    // 判断是否是track事件，track、track_xxx、自动采集事件
    BOOL isTrackEvent = [ThinkingAnalyticsSDK isTrackEvent:eventType];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    if (isTrackEvent) {
        // 静态公共属性
        [properties addEntriesFromDictionary:self.superProperty];
        // 动态公共属性
        NSDictionary *dynamicSuperPropertiesDict = self.dynamicSuperProperties?[self.dynamicSuperProperties() copy]:nil;
        if (dynamicSuperPropertiesDict && [dynamicSuperPropertiesDict isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:dynamicSuperPropertiesDict];
        }
    }
    
    // 外部属性
    if (properties && propertiesDictCopy && [propertiesDictCopy isKindOfClass:[NSDictionary class]]) {
        [properties addEntriesFromDictionary:propertiesDictCopy];
    }
    
    // 校验eventName的正确性
    // 判断是否是字符串，正则判断名字的是否符合要求
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
    
    // 校验属性
    if (properties && !isH5 && [TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone && ![self checkEventProperties:properties withEventType:eventType haveAutoTrackEvents:autotrack]) {
        NSString *errMsg = [NSString stringWithFormat:@"%@ The data contains invalid key or value.", properties];
        TDLogError(errMsg);
    }
    
    if (properties) {
        NSDictionary *propertiesDic = [TDCheck td_checkToJSONObjectRecursive:properties timeFormatter:_timeFormatter];
        return [propertiesDic copy];
    }
    
    return nil;
}

// 发送将数据库数据
- (void)flush {
    if (self.trackPause)
        return; // trackPause = YES 表示暂停数据网络上报
    [self _asyncWithCompletion:nil];
}

- (void)flushDebugEvent:(NSDictionary *)data {
    [self dispatchOnNetworkQueue:^{
        [self _syncDebug:data];
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
                dispatch_async(td_trackQueue, ^{
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
                dispatch_async(td_trackQueue, ^{
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

/// 异步同步数据（将本地数据库中的数据同步到TA）
/// 需要将此事件加到serialQueue队列中进行哦
/// 有些场景是事件入库和发送网络请求是同时发生的。事件入库是在serialQueue中进行，上报数据是在networkQueue中进行。如要确保事件入库在先，则需要将上报数据操作添加到serialQueue
- (void)_asyncWithCompletion:(void(^)(void))completion {
    dispatch_async(td_trackQueue, ^{
        dispatch_async(td_networkQueue, ^{
            [self _syncWithSize:kBatchSize completion:completion];
        });
    });
    
}

/// 同步数据（将本地数据库中的数据同步到TA）
/// @param size 每次从数据库中获取的最大条数，默认50条
/// @param completion 同步回调
/// 该方法需要在networkQueue中进行，会持续的发送网络请求直到数据库的数据被发送完
- (void)_syncWithSize:(NSUInteger)size completion:(void(^)(void))completion {
    
    // 判断是否满足发送条件
    NSString *networkType = [[self class] getNetWorkStates];
    if (!([self convertNetworkType:networkType] & self.config.networkTypePolicy)) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // 获取数据库数据，取前五十条数据，并更新这五十条数据的uuid
    // uuid的作用是数据库待删除数据的标识
    NSArray<NSDictionary *> *recordArray;
    NSArray *recodIds;
    NSArray *uuids;
    @synchronized (instances) {
        // 数据库里获取前kBatchSize条数据
        NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self td_getMapInstanceTag]];
        NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
        NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
        for (TDEventRecord *record in encryptRecords) {
            [indexs addObject:record.index];
            [recordContents addObject:record.event];
        }
        recodIds = indexs;
        recordArray = recordContents;
        
        // 更新uuid
        uuids = [self.dataQueue upadteRecordIds:recodIds];
    }
     
    // 数据库没有数据了
    if (recordArray.count == 0 || uuids.count == 0) {
        if (completion) {
            completion();
        }
        return;
    }
    
    // 网络情况较好，会在此处持续的将数据库中的数据发送完
    // 1，保证end事件发送成功
    BOOL flushSucc = YES;
    while (recordArray.count > 0 && uuids.count > 0 && flushSucc) {
        flushSucc = [self.network flushEvents:recordArray];
        if (flushSucc) {
            @synchronized (instances) {
                BOOL ret = [self.dataQueue removeDataWithuids:uuids];
                if (!ret) {
                    break;
                }
                // 数据库里获取前50条数据
                NSArray<TDEventRecord *> *records = [self.dataQueue getFirstRecords:kBatchSize withAppid:[self td_getMapInstanceTag]];
                NSArray<TDEventRecord *> *encryptRecords = [self encryptEventRecords:records];
                NSMutableArray *indexs = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                NSMutableArray *recordContents = [[NSMutableArray alloc] initWithCapacity:encryptRecords.count];
                for (TDEventRecord *record in encryptRecords) {
                    [indexs addObject:record.index];
                    [recordContents addObject:record.event];
                }
                recodIds = indexs;
                recordArray = recordContents;
                
                // 更新uuid
                uuids = [self.dataQueue upadteRecordIds:recodIds];
            }
        } else {
            break;
        }
    }
    if (completion) {
        completion();
    }
}


/// 开启加密后，上报的数据都需要是加密数据
/// 关闭加密后，上报数据既包含加密数据 也包含非加密数据
- (NSArray<TDEventRecord *> *)encryptEventRecords:(NSArray<TDEventRecord *> *)records {
    NSMutableArray *encryptRecords = [NSMutableArray arrayWithCapacity:records.count];
    
    if (_config.enableEncrypt && _encryptManager.isValid) {
        for (TDEventRecord *record in records) {
            // 数据解密了忽略啦
            if (record.encrypted) {
                [encryptRecords addObject:record];
            } else {
                // 缓存数据未加密，再加密
                NSDictionary *obj = [self.encryptManager encryptJSONObject:record.event];
                if (obj) {
                    [record setSecretObject:obj];
                    [encryptRecords addObject:record];
                }
            }
        }
        return encryptRecords.count == 0 ? records : encryptRecords;
    } else {
        return records;
    }
}

- (void)dispatchOnNetworkQueue:(void (^)(void))dispatchBlock {
    dispatch_async(td_trackQueue, ^{
        dispatch_async(td_networkQueue, dispatchBlock);
    });
}

#pragma mark - 自动采集类 - 懒加载
// todo: 此部分会重构到TDAutoTrackManager中
- (TDColdStartTracker *)startInitTracker {
    if (!_startInitTracker) {
        _startInitTracker = [TDColdStartTracker new];
    }
    return _startInitTracker;
}

- (TDInstallTracker *)installTracker {
    if (!_installTracker) {
        _installTracker = [TDInstallTracker new];
    }
    return _installTracker;
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
- (void) enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    [self _enableAutoTrack:eventType properties:nil callback:nil];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    [self _enableAutoTrack:eventType properties:properties callback:nil];
}

- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback {
    [self _enableAutoTrack:eventType properties:nil callback:callback];
}

- (void)_enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback {
    
    // 未开启不采集
    if ([self hasDisabled])
        return;
    
    // 整理自动采集自定义属性
    [self setAutoTrackProperties:eventType properties:properties];
    
    // 更新自动采集回调
    self.autoTrackCallback = callback;
    
    // 走原来方法
    [self _enableAutoTrack:eventType];
}

- (void)_enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType {
    
    _config.autoTrackEventType = eventType;
    
    //安装事件
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppInstall) {
        [self.installTracker trackWithInstanceTag:[self td_getMapInstanceTag]
                                        eventName:TD_APP_INSTALL_EVENT
                                           params:nil];
    }
    
    // 开始记录end事件时长
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppEnd) {
        [self timeEvent:TD_APP_END_EVENT];
    }

    if ([TDPresetProperties disableStartReason]) {
        // 不需要采集启动原因，走原来的逻辑
        if (self && (self.config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart)) {
            [self.startInitTracker trackWithInstanceTag:[self td_getMapInstanceTag]
                                              eventName:[self getStartEventName]
                                                 params:[self getStartEventPresetProperties:YES]];
        }
    } else {
        // 为了兼容老用户是在didfinish方法中初始化SDK，且为了老用户有更好的接入体验， 所以收集冷启动原因需要延迟到didfinish方法之后，这里采用runloop特性，即在下一次runloop的时候再去发送start事件
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self && (self.config.autoTrackEventType & ThinkingAnalyticsEventTypeAppStart)) {
                [self.startInitTracker trackWithInstanceTag:[self td_getMapInstanceTag]
                                                  eventName:[self getStartEventName]
                                                     params:[self getStartEventPresetProperties:YES]];
            }
        });
    }
    
    // 开启监听界面点击、界面浏览事件
    [_autoTrackManager trackWithAppid:[self td_getMapInstanceTag] withOption:eventType];
    
    // 开启监听crash
    if (_config.autoTrackEventType & ThinkingAnalyticsEventTypeAppViewCrash) {
        [self trackCrash];
    }
}

- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    
    // 未开启不更新数据
    if ([self hasDisabled])
        return;
    
    if (properties == nil) {
        return;
    }
    
    if ([TDLogging sharedInstance].loggingLevel != TDLoggingLevelNone && ![self checkEventProperties:properties withEventType:nil haveAutoTrackEvents:NO]) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    
    // 深拷贝传入数据
    if (properties && [properties isKindOfClass:[NSDictionary class]]) {
        properties = [properties copy];
    }
    
    @synchronized (self) {
        if (!_autoCustomProperty) _autoCustomProperty = [NSMutableDictionary dictionary];
        [self _setAutoTrackProperties:eventType properties:properties];
    }
}

- (void)_setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties {
    
    // 自动采集，枚举值和事件名 映射关系
    NSArray<NSDictionary<NSNumber *, NSString *> *> *autoTypes = @[@{@(ThinkingAnalyticsEventTypeAppStart):TD_APP_START_EVENT},
                                                                   @{@(ThinkingAnalyticsEventTypeAppEnd):TD_APP_END_EVENT},
                                                                   @{@(ThinkingAnalyticsEventTypeAppClick):TD_APP_CLICK_EVENT},
                                                                   @{@(ThinkingAnalyticsEventTypeAppInstall):TD_APP_INSTALL_EVENT},
                                                                   @{@(ThinkingAnalyticsEventTypeAppViewCrash):TD_APP_CRASH_EVENT},
                                                                   @{@(ThinkingAnalyticsEventTypeAppViewScreen):TD_APP_VIEW_EVENT}];
    
    __weak __typeof(self)weakSelf = self;
    [autoTypes enumerateObjectsUsingBlock:^(NSDictionary<NSNumber *,NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ThinkingAnalyticsAutoTrackEventType type = obj.allKeys.firstObject.integerValue;
        if ((eventType & type) == type) {
            NSString *eventName = obj.allValues.firstObject;
            if (properties) {
                
                // 覆盖之前的，先取出之前的属性进行覆盖；之前没有该属性就直接设置
                NSDictionary *oldProperties = weakSelf.autoCustomProperty[eventName];
                if (oldProperties && [oldProperties isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutiOldProperties = [oldProperties mutableCopy];
                    [mutiOldProperties addEntriesFromDictionary:properties];
                    [weakSelf.autoCustomProperty setObject:mutiOldProperties forKey:eventName];
                } else {
                    [weakSelf.autoCustomProperty setObject:properties forKey:eventName];
                }
                
                // 后台自启动，
                if (type == ThinkingAnalyticsEventTypeAppStart) {
                    NSDictionary *startParam = weakSelf.autoCustomProperty[TD_APP_START_EVENT];
                    if (startParam && [startParam isKindOfClass:[NSDictionary class]]) {
                        [weakSelf.autoCustomProperty setObject:startParam forKey:TD_APP_START_BACKGROUND_EVENT];
                    }
                }
            }
        }
    }];
}

- (NSString *)getStartEventName {
    NSString *eventName = _relaunchInBackGround?TD_APP_START_BACKGROUND_EVENT:TD_APP_START_EVENT;
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        if (_isEnableSceneSupport) {
            eventName = TD_APP_START_EVENT;
        }
    }
#endif
    return [eventName copy];
}

- (void)ignoreViewType:(Class)aClass {
    if ([self hasDisabled])
        return;
    
    dispatch_async(td_trackQueue, ^{
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
    
    dispatch_async(td_trackQueue, ^{
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

#pragma mark - Start Event

// isFirst 是否是调用enable方法进入的
- (NSDictionary *)getStartEventPresetProperties:(BOOL)isFirst {
    
    NSMutableDictionary *dicProperties = [NSMutableDictionary dictionary];
    dicProperties[TD_RESUME_FROM_BACKGROUND] = @(_appRelaunched);

    // 启动原因
    NSString *reason = [TDRunTime getAppLaunchReason];
    if (!TDPresetProperties.disableStartReason && reason && reason.length) {
        dicProperties[TD_START_REASON] = reason;
    }
    
    // 后台时间
    double bg_duration = td_enterDidBecomeActiveTime - td_enterBackgroundTime;
    if (bg_duration <0 || isFirst) bg_duration = 0;
    dicProperties[TD_BACKGROUND_DURATION] = [NSNumber numberWithDouble:bg_duration];
    
    return dicProperties;
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
