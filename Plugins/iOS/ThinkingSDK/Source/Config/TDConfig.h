#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDConstant.h>)
#import <ThinkingSDK/TDConstant.h>
#else
#import "TDConstant.h"
#endif

#if __has_include(<ThinkingSDK/TDSecurityPolicy.h>)
#import <ThinkingSDK/TDSecurityPolicy.h>
#else
#import "TDSecurityPolicy.h"
#endif

#if TARGET_OS_IOS
#if __has_include(<ThinkingSDK/TDSecretKey.h>)
#import <ThinkingSDK/TDSecretKey.h>
#else
#import "TDSecretKey.h"
#endif
#endif



NS_ASSUME_NONNULL_BEGIN



@interface TDConfig:NSObject <NSCopying>
/**
 Set automatic burying type
 */
@property (assign, nonatomic) ThinkingAnalyticsAutoTrackEventType autoTrackEventType;
/**
 Network environment for data transmission
 */
@property (assign, nonatomic) ThinkingNetworkType networkTypePolicy;
/**
 Data upload interval
 */
@property (nonatomic, strong) NSNumber *uploadInterval;
/**
 When there is data to upload, when the number of data cache reaches the uploadsize, upload the data immediately
 */
@property (nonatomic, strong) NSNumber *uploadSize;
/**
 Event blacklist, event names that are not counted are added here
 */
@property (strong, nonatomic) NSArray *disableEvents;
/**
 The maximum number of cached events, the default is 10000, the minimum is 5000
 */
@property (class,  nonatomic) NSInteger maxNumEvents DEPRECATED_MSG_ATTRIBUTE("Please config TAConfigInfo in main info.plist");
/**
 Data cache expiration time, the default is 10 days, the longest is 10 days
 */
@property (class,  nonatomic) NSInteger expirationDays DEPRECATED_MSG_ATTRIBUTE("Please config TAConfigInfo in main info.plist");
/**
 appid
 */
@property (atomic, copy) NSString *appid;
/**
 instance Token
 */
@property (atomic, copy) NSString *(^getInstanceName)(void);
/**
 Server URL
 */
@property (atomic, copy) NSString *configureURL;

/**
 Initialize and configure background self-starting events
 YES: Collect background self-starting events
 NO: Do not collect background self-starting events
 */
@property (nonatomic, assign) BOOL trackRelaunchedInBackgroundEvents;
/**
 Debug Mode
*/
@property (nonatomic, assign) ThinkingAnalyticsDebugMode debugMode;

/**
app launchOptions
*/
@property (nonatomic, copy) NSDictionary *launchOptions;

/**
 Initialize and configure the certificate verification policy
*/
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;

/**
 Set default time zone
  You can use this time zone to compare the offset of the current time zone and the default time zone
*/
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

/**
 instance name
*/
@property (nonatomic, copy) NSString *name;

+ (TDConfig *)defaultTDConfig;
- (instancetype)initWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl;
- (void)updateConfig:(void(^)(NSDictionary *secretKey))block;
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;


/// enable encryption
@property (nonatomic, assign) BOOL enableEncrypt;

#if TARGET_OS_IOS
/// Get local key configuration
@property (nonatomic, strong) TDSecretKey *secretKey;
#endif

/// instance token
- (NSString *)getMapInstanceToken;

@end
NS_ASSUME_NONNULL_END
