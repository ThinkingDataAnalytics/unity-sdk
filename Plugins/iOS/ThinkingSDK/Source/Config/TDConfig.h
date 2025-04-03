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

/// app id
@property (atomic, copy) NSString *appid;

/// server url
@property (atomic, copy) NSString *serverUrl;

/// SDK mode
@property (nonatomic, assign) TDMode mode;

/// Set default time zone.
/// You can use this time zone to compare the offset of the current time zone and the default time zone
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

/// SDK instance name
@property (nonatomic, copy) NSString *name;

/// Set the network environment for reporting data
@property (nonatomic, assign) TDReportingNetworkType reportingNetworkType;

/// Data upload interval
@property (nonatomic, strong) NSNumber *uploadInterval;

/// When there is data to upload, when the number of data cache reaches the uploadsize, upload the data immediately
@property (nonatomic, strong) NSNumber *uploadSize;

/// Event blacklist, event names that are not counted are added here
@property (strong, nonatomic) NSArray *disableEvents;

/// instance Token
@property (atomic, copy) NSString *(^getInstanceName)(void);

/// Initialize and configure background self-starting events
/// YES: Collect background self-starting events
/// NO: Do not collect background self-starting events
@property (nonatomic, assign) BOOL trackRelaunchedInBackgroundEvents;

/// app launchOptions
@property (nonatomic, copy) NSDictionary *launchOptions;

/// Initialize and configure the certificate verification policy
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;

/// share data with App Extension
@property (nonatomic, copy) NSString *appGroupName;

@property (nonatomic, assign) BOOL enableAutoPush;

/// Enable the automatic time calibration function
@property (nonatomic, assign) BOOL enableAutoCalibrated;

/// server url
@property (nonatomic, copy) NSString *configureURL DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with property: serverUrl");

#if TARGET_OS_IOS
/// enable encryption
@property (nonatomic, assign) BOOL enableEncrypt DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: -enableEncryptWithVersion:publicKey:");
/// Get local key configuration
@property (nonatomic, strong) TDSecretKey *secretKey DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: -enableEncryptWithVersion:publicKey:");
#endif
/**
 Debug Mode
*/
@property (nonatomic, assign) ThinkingAnalyticsDebugMode debugMode DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with property: mode");
/**
 Network environment for data transmission
 */
@property (assign, nonatomic) ThinkingNetworkType networkTypePolicy DEPRECATED_MSG_ATTRIBUTE("Deprecated. don't need this property");
/**
 Set automatic burying type
 */
@property (assign, nonatomic) ThinkingAnalyticsAutoTrackEventType autoTrackEventType DEPRECATED_MSG_ATTRIBUTE("Deprecated. don't need this property");
/**
 The maximum number of cached events, the default is 10000, the minimum is 5000
 */
@property (class,  nonatomic) NSInteger maxNumEvents DEPRECATED_MSG_ATTRIBUTE("Please config TAConfigInfo in main info.plist");
/**
 Data cache expiration time, the default is 10 days, the longest is 10 days
 */
@property (class,  nonatomic) NSInteger expirationDays DEPRECATED_MSG_ATTRIBUTE("Please config TAConfigInfo in main info.plist");

- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: -setUploadNetworkType:");
- (void)updateConfig:(void(^)(NSDictionary *dict))block DEPRECATED_MSG_ATTRIBUTE("Deprecated");
- (NSString *)getMapInstanceToken DEPRECATED_MSG_ATTRIBUTE("Deprecated");
+ (TDConfig *)defaultTDConfig DEPRECATED_MSG_ATTRIBUTE("Deprecated");

/// Initialize the SDK config file
/// @param appId  project app Id
/// @param serverUrl Thinking Engine receiver url
- (instancetype)initWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl;

/// enable encrypt
/// @param version version of the encryption configuration file
/// @param publicKey public key
- (void)enableEncryptWithVersion:(NSUInteger)version publicKey:(NSString *)publicKey;

/// enable DNS parse. Must close ATS in info.plist.
/// @param services DNS service list
- (void)enableDNSServcie:(NSArray<TDDNSService> *)services;

@end
NS_ASSUME_NONNULL_END
