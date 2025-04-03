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
#import "TDAutoTrackEvent.h"
#import "TDAutoTrackSuperProperty.h"
#import "TDEncrypt.h"
#else
#import "TDAutoTrackConst.h"
#endif

#import "TDLogging.h"
#import "TDDeviceInfo.h"
#import "TDCommonUtil.h"
#import "TDConfig.h"
#import "TDSqliteDataQueue.h"
#import "TDEventModel.h"

#import "TDTrackTimer.h"
#import "TDSuperProperty.h"
#import "TDTrackEvent.h"
#import "TDTrackFirstEvent.h"
#import "TDTrackOverwriteEvent.h"
#import "TDTrackUpdateEvent.h"
#import "TDUserPropertyHeader.h"
#import "TDPropertyPluginManager.h"
#import "TDPresetPropertyPlugin.h"
#import "TDBaseEvent+H5.h"
#import "TDEventTracker.h"
#import "TDAppLifeCycle.h"

#if __has_include(<ThinkingDataCore/NSDate+TDCore.h>)
#import <ThinkingDataCore/NSDate+TDCore.h>
#else
#import "NSDate+TDCore.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#ifndef td_dispatch_main_sync_safe
#define td_dispatch_main_sync_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#define kDefaultTimeFormat  @"yyyy-MM-dd HH:mm:ss.SSS"

@interface ThinkingAnalyticsSDK ()

@property (atomic, copy, nullable) NSString *accountId;
@property (atomic, copy) NSString *identifyId;
/// TD error callback
@property (atomic, copy) void(^errorCallback)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext);
@property (atomic, assign, getter=isTrackPause) BOOL trackPause;
@property (atomic, assign) BOOL isEnabled;
@property (nonatomic, strong) TDConfig *config;
@property (atomic, strong) NSMutableSet *ignoredViewControllers;
@property (atomic, strong) NSMutableSet *ignoredViewTypeList;

#if TARGET_OS_IOS
@property (nonatomic, strong) TDAutoTrackSuperProperty *autoTrackSuperProperty;
@property (nonatomic, strong) TDEncryptManager *encryptManager;
- (void)autoTrackWithEvent:(TDAutoTrackEvent *)event properties:(nullable NSDictionary *)properties;
- (BOOL)isViewControllerIgnored:(UIViewController *)viewController;
#endif


+ (dispatch_queue_t)sharedTrackQueue;
+ (dispatch_queue_t)sharedNetworkQueue;

// TAThirdParty model used.
- (NSString *)getAccountId;
- (BOOL)hasDisabled;
+ (BOOL)isTrackEvent:(NSString *)eventType;
- (void)startFlushTimer;
+ (NSMutableDictionary *)_getAllInstances;
+ (NSString *)defaultAppId;
- (void)asyncTrackEventObject:(TDTrackEvent *)event properties:(NSDictionary * _Nullable)properties isH5:(BOOL)isH5;
- (void)asyncUserEventObject:(TDUserEvent *)event properties:(NSDictionary * _Nullable)properties isH5:(BOOL)isH5;

- (instancetype)initWithConfig:(TDConfig *)config;
- (instancetype)initLight:(NSString *)appid withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

+ (nullable ThinkingAnalyticsSDK *)defaultInstance;
+ (nullable ThinkingAnalyticsSDK *)instanceWithAppid:(NSString *)appid;

- (void)innerTrack:(NSString *)event;
- (void)innerTrack:(NSString *)event properties:(NSDictionary * _Nullable)propertieDict;
- (void)innerTrack:(NSString *)event properties:(NSDictionary * _Nullable)propertieDict time:(NSDate * _Nullable)time timeZone:(NSTimeZone * _Nullable)timeZone;
- (void)innerTrackWithEventModel:(TDEventModel *)eventModel;
- (void)innerTrackDebug:(NSString *)event properties:(NSDictionary * _Nullable)propertieDict;
- (void)innerTimeEvent:(NSString *)event;
- (NSString *)innerAccountId;
- (NSString *)innerDistinctId;
- (void)innerSetIdentify:(NSString *)distinctId;
- (void)innerLogin:(NSString *)accountId;
- (void)innerLogout;
- (void)innerUserSet:(NSDictionary *)properties;
- (void)innerUserUnset:(NSString *)propertyName;
- (void)innerUserUnsets:(NSArray<NSString *> *)propertyNames;
- (void)innerUserSetOnce:(NSDictionary *)properties;
- (void)innerUserAdd:(NSDictionary *)properties;
- (void)innerUserAdd:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;
- (void)innerUserDelete;
- (void)innerUserAppend:(NSDictionary<NSString *, NSArray *> *)properties;
- (void)innerUserUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties;

- (void)innerSetSuperProperties:(NSDictionary *)properties;
- (void)innerUnsetSuperProperty:(NSString *)property;
- (void)innerClearSuperProperties;
- (NSDictionary *)innerCurrentSuperProperties;
- (void)innerRegisterDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties;
- (void)innerRegisterErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback;
- (TDPresetProperties *)innerGetPresetProperties;
- (void)innerSetNetworkType:(TDReportingNetworkType)type;

- (BOOL)innerIsViewTypeIgnored:(Class)aClass;

- (void)innerFlush;
- (void)innerSetTrackStatus:(TDTrackStatus)status;
- (ThinkingAnalyticsSDK *)innerCreateLightInstance;
- (NSString *)innetGetTimeString:(NSDate *)date;
- (NSString *)instanceAliasNameOrAppId;
@end

@interface TDEventModel ()
@property (nonatomic, copy) NSString *extraID;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSTimeZone *timeZone;
- (instancetype _Nonnull )initWithEventName:(NSString * _Nullable)eventName eventType:(kEDEventTypeName _Nonnull )eventType;
@end

@interface LightThinkingAnalyticsSDK : ThinkingAnalyticsSDK

- (instancetype)initWithAPPID:(NSString *)appID withServerURL:(NSString *)serverURL withConfig:(TDConfig *)config;

@end

NS_ASSUME_NONNULL_END
