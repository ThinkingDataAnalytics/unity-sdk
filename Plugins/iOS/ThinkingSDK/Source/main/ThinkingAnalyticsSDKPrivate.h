#if __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#else
#import "ThinkingAnalyticsSDK.h"
#endif

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

#if TARGET_OS_IOS
#import "ThinkingExceptionHandler.h"
#import "TAAutoTrackEvent.h"
#import "TAAutoTrackSuperProperty.h"
#import "TDEncrypt.h"
#endif

#import "TDLogging.h"
#import "TDDeviceInfo.h"
#import "TDConfig.h"
#import "TDSqliteDataQueue.h"
#import "TDEventModel.h"

#import "TATrackTimer.h"
#import "TASuperProperty.h"
#import "TATrackEvent.h"
#import "TATrackFirstEvent.h"
#import "TATrackOverwriteEvent.h"
#import "TATrackUpdateEvent.h"
#import "TAUserPropertyHeader.h"
#import "TAPropertyPluginManager.h"
//#import "TASessionIdPropertyPlugin.h"
#import "TAPresetPropertyPlugin.h"
#import "TABaseEvent+H5.h"
#import "NSDate+TAFormat.h"
#import "TAEventTracker.h"
#import "TAAppLifeCycle.h"

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

#if TARGET_OS_IOS
@property (nonatomic, strong) TAAutoTrackSuperProperty *autoTrackSuperProperty;
@property (nonatomic, strong) TDEncryptManager *encryptManager;
@property (strong,nonatomic) id thirdPartyManager;
#endif

@property (atomic, copy) NSString *appid;
@property (atomic, copy) NSString *serverURL;
@property (atomic, copy, nullable) NSString *accountId;
@property (atomic, copy) NSString *identifyId;
@property (nonatomic, strong) TASuperProperty *superProperty;
@property (nonatomic, strong) TAPropertyPluginManager *propertyPluginManager;
//@property (nonatomic, strong) TASessionIdPropertyPlugin *sessionidPlugin;
@property (nonatomic, strong) TAAppLifeCycle *appLifeCycle;
/// TD error callback
@property (atomic, copy) void(^errorCallback)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext);

@property (atomic, strong) NSMutableSet *ignoredViewTypeList;
@property (atomic, strong) NSMutableSet *ignoredViewControllers;


@property (atomic, assign, getter=isTrackPause) BOOL trackPause;
@property (atomic, assign) BOOL isEnabled;
@property (atomic, assign) BOOL isOptOut;


@property (nonatomic, strong, nullable) NSTimer *timer;

@property (nonatomic, strong) TATrackTimer *trackTimer;

@property (atomic, strong) TDSqliteDataQueue *dataQueue;
@property (nonatomic, copy) TDConfig *config;
@property (nonatomic, strong) WKWebView *wkWebView;

#if TARGET_OS_IOS
- (void)autoTrackWithEvent:(TAAutoTrackEvent *)event properties:(nullable NSDictionary *)properties;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
- (BOOL)isAutoTrackEventTypeIgnored:(ThinkingAnalyticsAutoTrackEventType)eventType;
- (BOOL)isViewTypeIgnored:(Class)aClass;
#endif

- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

- (void)retrievePersistedData;
+ (dispatch_queue_t)td_trackQueue;
+ (dispatch_queue_t)td_networkQueue;
+ (id)sharedUIApplication;
- (NSInteger)saveEventsData:(NSDictionary *)data;
- (void)flushImmediately:(NSDictionary *)dataDic;
- (BOOL)hasDisabled;
- (BOOL)isValidName:(NSString *)name isAutoTrack:(BOOL)isAutoTrack;
+ (BOOL)isTrackEvent:(NSString *)eventType;
- (BOOL)checkEventProperties:(NSDictionary *)properties withEventType:(NSString *_Nullable)eventType haveAutoTrackEvents:(BOOL)haveAutoTrackEvents;
- (void)startFlushTimer;
- (double)getTimezoneOffset:(NSDate *)date timeZone:(NSTimeZone *)timeZone;
+ (NSMutableDictionary *)_getAllInstances;

+ (NSMutableDictionary *)_getAllInstances;

@end

@interface TDEventModel ()

@property (nonatomic, copy) NSString *timeString;
@property (nonatomic, assign) double zoneOffset;
@property (nonatomic, assign) TimeValueType timeValueType;
@property (nonatomic, copy) NSString *extraID;
@property (nonatomic, assign) BOOL persist;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSTimeZone *timeZone;

- (instancetype)initWithEventName:(NSString * _Nullable)eventName;

- (instancetype _Nonnull )initWithEventName:(NSString * _Nullable)eventName eventType:(kEDEventTypeName _Nonnull )eventType;

@end

@interface LightThinkingAnalyticsSDK : ThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

@end

NS_ASSUME_NONNULL_END
