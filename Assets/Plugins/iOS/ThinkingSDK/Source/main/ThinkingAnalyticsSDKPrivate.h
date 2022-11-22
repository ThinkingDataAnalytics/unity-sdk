#import "ThinkingAnalyticsSDK.h"

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

#import "TDLogging.h"
#import "ThinkingExceptionHandler.h"
#import "TDDeviceInfo.h"
#import "TDConfig.h"
#import "TDSqliteDataQueue.h"
#import "TDEventModel.h"
#import "TATrackTimer.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const TD_APP_START_EVENT                  = @"ta_app_start";
static NSString * const TD_APP_START_BACKGROUND_EVENT       = @"ta_app_bg_start";
static NSString * const TD_APP_END_EVENT                    = @"ta_app_end";
static NSString * const TD_APP_VIEW_EVENT                   = @"ta_app_view";
static NSString * const TD_APP_CLICK_EVENT                  = @"ta_app_click";
static NSString * const TD_APP_CRASH_EVENT                  = @"ta_app_crash";
static NSString * const TD_APP_INSTALL_EVENT                = @"ta_app_install";

static NSString * const TD_CRASH_REASON                     = @"#app_crashed_reason";
static NSString * const TD_RESUME_FROM_BACKGROUND           = @"#resume_from_background";
static NSString * const TD_START_REASON                     = @"#start_reason";
static NSString * const TD_BACKGROUND_DURATION              = @"#background_duration";

static kEDEventTypeName const TD_EVENT_TYPE_TRACK           = @"track";

static kEDEventTypeName const TD_EVENT_TYPE_USER_DEL        = @"user_del";
static kEDEventTypeName const TD_EVENT_TYPE_USER_ADD        = @"user_add";
static kEDEventTypeName const TD_EVENT_TYPE_USER_SET        = @"user_set";
static kEDEventTypeName const TD_EVENT_TYPE_USER_SETONCE    = @"user_setOnce";
static kEDEventTypeName const TD_EVENT_TYPE_USER_UNSET      = @"user_unset";
static kEDEventTypeName const TD_EVENT_TYPE_USER_APPEND     = @"user_append";
static kEDEventTypeName const TD_EVENT_TYPE_USER_UNIQ_APPEND= @"user_uniq_append";

static char TD_AUTOTRACK_VIEW_ID;
static char TD_AUTOTRACK_VIEW_ID_APPID;
static char TD_AUTOTRACK_VIEW_IGNORE;
static char TD_AUTOTRACK_VIEW_IGNORE_APPID;
static char TD_AUTOTRACK_VIEW_PROPERTIES;
static char TD_AUTOTRACK_VIEW_PROPERTIES_APPID;
static char TD_AUTOTRACK_VIEW_DELEGATE;

#ifndef td_dispatch_main_sync_safe
#define td_dispatch_main_sync_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#define kDefaultTimeFormat  @"yyyy-MM-dd HH:mm:ss.SSS"

static NSUInteger const kBatchSize = 50;
static NSUInteger const TA_PROPERTY_CRASH_LENGTH_LIMIT = 8191*2;
static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";

#define kModeEnumArray @"NORMAL", @"DebugOnly", @"Debug", nil

@interface ThinkingAnalyticsSDK ()

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *serverURL;
@property (atomic, copy, nullable) NSString *accountId;
@property (atomic, copy) NSString *identifyId;
@property (atomic, strong) NSDictionary *superProperty;
@property (atomic, strong) NSMutableDictionary *autoCustomProperty;// 自动采集自定义属性
@property (atomic, copy) NSDictionary*(^autoTrackCallback)(ThinkingAnalyticsAutoTrackEventType type, NSDictionary *properties);// 自动采集回调
@property (atomic, strong) NSMutableSet *ignoredViewTypeList;
@property (atomic, strong) NSMutableSet *ignoredViewControllers;
@property (nonatomic, assign) BOOL relaunchInBackGround;// 标识是否是后台自启动事件

/// 标识是否暂停网络上报，默认 NO 上报网络正常流程；YES 入本地数据库但不网络上报
@property (atomic, assign, getter=isTrackPause) BOOL trackPause;

@property (nonatomic, assign) BOOL isEnabled;
@property (atomic, assign) BOOL isOptOut;

@property (nonatomic, strong, nullable) NSTimer *timer;
@property (nonatomic, strong) NSPredicate *regexKey;
@property (nonatomic, strong) NSPredicate *regexAutoTrackKey;
@property (nonatomic, strong) TATrackTimer *trackTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier taskId;
@property (nonatomic, assign) SCNetworkReachabilityRef reachability;
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);

@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (nonatomic, copy) TDConfig *config;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;
@property (nonatomic, assign) BOOL applicationWillResignActive;
@property (nonatomic, assign) BOOL appRelaunched;
@property (nonatomic, assign) BOOL isEnableSceneSupport;// 标识APP是不是Scene方法启动，IOS13以后版本才需要用到
@property (nonatomic, strong) WKWebView *wkWebView;

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;
- (void)autotrack:(NSString *)event properties:(NSDictionary *_Nullable)propertieDict withTime:(NSDate *_Nullable)date;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isViewTypeIgnored:(Class)aClass;
- (void)retrievePersistedData;
+ (dispatch_queue_t)td_trackQueue;
+ (dispatch_queue_t)td_networkQueue;
+ (UIApplication *)sharedUIApplication;
- (NSInteger)saveEventsData:(NSDictionary *)data;
- (void)flushImmediately:(NSDictionary *)dataDic;
- (BOOL)hasDisabled;
- (BOOL)isValidName:(NSString *)name isAutoTrack:(BOOL)isAutoTrack;
+ (BOOL)isTrackEvent:(NSString *)eventType;
- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *_Nullable)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents;
- (void)startFlushTimer;
- (double)getTimezoneOffset:(NSDate *)date timeZone:(NSTimeZone *)timeZone;

@end

@interface TDEventModel ()

@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, assign) double zoneOffset;
@property (nonatomic, assign) TimeValueType timeValueType;
@property (nonatomic, copy) NSString *extraID;
@property (nonatomic, assign) BOOL persist;

- (instancetype)initWithEventName:(NSString * _Nullable)eventName;

- (instancetype _Nonnull )initWithEventName:(NSString * _Nullable)eventName eventType:(kEDEventTypeName _Nonnull )eventType;

@end

@interface LightThinkingAnalyticsSDK : ThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

@end

NS_ASSUME_NONNULL_END
