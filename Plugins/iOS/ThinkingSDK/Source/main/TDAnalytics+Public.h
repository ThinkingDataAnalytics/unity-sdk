//
//  TDAnalytics+Public.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#if __has_include(<ThinkingSDK/TDAnalytics.h>)
#import <ThinkingSDK/TDAnalytics.h>
#else
#import "TDAnalytics.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalytics (Public)

//MARK: SDK info
+ (void)enableLog:(BOOL)enable;
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;
+ (void)calibrateTime:(NSTimeInterval)timestamp;
+ (nullable NSString *)getLocalRegion;
+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion;
/**
 Get sdk version
 
 @return version string
 */
+ (NSString *)getSDKVersion;
/**
 Get DeviceId
 
 @return deviceId
 */
+ (NSString *)getDeviceId;
/**
 Format the time output in the format of SDK
 @param date date
 @return date string
 */
+ (NSString *)timeStringWithDate:(NSDate *)date;

//MARK: - init

/**
  Initialization method
  After the SDK initialization is complete, the saved instance can be obtained through this api

  @param appId appId
  @param url server url
  */
+ (void)startAnalyticsWithAppId:(NSString *)appId serverUrl:(NSString *)url;

/**
  Initialization method
  After the SDK initialization is complete, the saved instance can be obtained through this api

  @param config initialization configuration
  */
+ (void)startAnalyticsWithConfig:(nullable TDConfig *)config;

/// Create light instance based on original instance
/// @param appId appId
/// @return light instance appId
+ (NSString * _Nullable)lightInstanceIdWithAppId:(NSString * _Nonnull)appId;

//MARK: track

/**
 Empty the cache queue. When this api is called, the data in the current cache queue will attempt to be reported.
 If the report succeeds, local cache data will be deleted.
 */
+ (void)flush;

/**
 Switch reporting status
 @param status TDTrackStatus reporting status
 */
+ (void)setTrackStatus:(TDTrackStatus)status;

/**
 Track Events
 @param eventName event name
 */
+ (void)track:(NSString *)eventName;
/**
 Track Events
 @param eventName  event name
 @param properties event properties
 */
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties;
/**
 Track Events
 @param eventName event name
 @param properties event properties
 @param time event trigger time
 @param timeZone event trigger time time zone
 */
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone;
/**
 Track Events
 @param eventModel event Model
 */
+ (void)trackWithEventModel:(TDEventModel *)eventModel;
/**
 Timing Events
 Record the event duration, call this method to start the timing, stop the timing when the target event is uploaded, and add the attribute #duration to the event properties, in seconds.
 */
+ (void)timeEvent:(NSString *)eventName;


//MARK: user property

/**
 Sets the user property, replacing the original value with the new value if the property already exists.
 @param properties user properties
 */
+ (void)userSet:(NSDictionary<NSString *, id> *)properties;
/**
 Sets a single user attribute, ignoring the new attribute value if the attribute already exists.
 @param properties user properties
 */
+ (void)userSetOnce:(NSDictionary<NSString *, id> *)properties;
/**
 Reset single user attribute.
 @param propertyName user properties
 */
+ (void)userUnset:(NSString *)propertyName;
/**
 Reset user properties.
 @param propertyNames user properties
*/
+ (void)userUnsets:(NSArray<NSString *> *)propertyNames;
/**
 Adds the numeric type user attributes.
 @param properties user properties
 */
+ (void)userAdd:(NSDictionary<NSString *, id> *)properties;
/**
 Adds the numeric type user attribute.
 @param propertyName  propertyName
 @param propertyValue propertyValue
 */
+ (void)userAddWithName:(NSString *)propertyName andValue:(NSNumber *)propertyValue;
/**
 Appends an element to a property of an array type.
 @param properties user properties
 */
+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties;
/**
 Appends an element to a property of an array type. It filters out elements that already exist.
 @param properties user properties
*/
+ (void)userUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties;
/**
 Delete the user attributes. This operation is not reversible and should be performed with caution.
 */
+ (void)userDelete;


//MARK: super property & preset property

/**
 Set the public event attribute, which will be included in every event uploaded after that. The public event properties are saved without setting them each time.
 @param properties super properties
 */
+ (void)setSuperProperties:(NSDictionary<NSString *, id> *)properties;
/**
 Clears a public event attribute.
 @param property property name
 */
+ (void)unsetSuperProperty:(NSString *)property;
/**
 Clear all public event attributes.
 */
+ (void)clearSuperProperties;
/**
 Get the public event properties that have been set.
 
 @return super properties that have been set.
 */
+ (NSDictionary *)getSuperProperties;
/**
 Set dynamic public properties. Each event uploaded after that will contain a public event attribute.
 @param propertiesHandler  propertiesHandler.
 */
+ (void)setDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))propertiesHandler;
/**
 Get the SDK's preset properties.
 
 @return preset property object
 */
+ (TDPresetProperties *)getPresetProperties;

//MARK: error callback

/**
 Register TD error callback
 
 @param errorCallback code = 10001, ext = "string or json string", errorMsg = "error"
 */
+ (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback;


//MARK: custom property

/**
 Set the distinct ID to replace the default UUID distinct ID.
 @param distinctId distinctId
 */
+ (void)setDistinctId:(NSString *)distinctId;

/**
 Get distinct ID: The #distinct_id value in the reported data.
 
 @return distinctId
 */
+ (NSString *)getDistinctId;

/**
 Set the account ID. Each setting overrides the previous value. Login events will not be uploaded.
 @param accountId accountId
 */
+ (void)login:(NSString *)accountId;

/**
 Get account ID: The #account_id value in the reported data.
 
 @return accountId
 */
+ (NSString *)getAccountId;

/**
 Clearing the account ID will not upload user logout events.
 */
+ (void)logout;

/**
 Set the network conditions for uploading. By default, the SDK will set the network conditions as 3G, 4G and Wifi to upload data
 @param type network type
 */
+ (void)setUploadingNetworkType:(TDReportingNetworkType)type;

#if TARGET_OS_IOS

/**
 Enable Auto-Tracking
 @param eventType Auto-Tracking type
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType API_UNAVAILABLE(macos);
/**
 Enable auto tracking with super properties.
 @param eventType  Auto-Tracking type
 @param properties super properties
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties API_UNAVAILABLE(macos);

/**
 Enable the auto tracking function.
 @param eventType  Auto-Tracking type
 @param callback In the callback, eventType indicates the type of automatic collection, properties indicates the event properties before storage, and this block can return a dictionary for adding new properties
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType callback:(NSDictionary *(^_Nullable)(TDAutoTrackEventType eventType, NSDictionary *properties))callback API_UNAVAILABLE(macos);

/**
 Set and Update the value of a custom property for Auto-Tracking
 @param eventType  A list of TDAutoTrackEventType, indicating the types of automatic collection events that need to be enabled
 @param properties properties
 */
+ (void)setAutoTrackProperties:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties API_UNAVAILABLE(macos);

/**
 Ignore the Auto-Tracking of a UIViewController
 @param controllers Ignore the name of the UIViewController
 */
+ (void)ignoreAutoTrackViewControllers:(NSArray<NSString *> *)controllers API_UNAVAILABLE(macos);

/**
 Ignore the Auto-Tracking  of click UIView
 @param aClass ignored UIView  Class
 */
+ (void)ignoreViewType:(Class)aClass API_UNAVAILABLE(macos);

/**
 Dynamic super properties in  auto track  environment
 Set dynamic public properties for auto track event
 */
+ (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties API_UNAVAILABLE(macos);

#endif

@end

NS_ASSUME_NONNULL_END
