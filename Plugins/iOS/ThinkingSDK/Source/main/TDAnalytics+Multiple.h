//
//  TDAnalytics+Multiple.h
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

@interface TDAnalytics (Multiple)

//MARK: track

/**
 Empty the cache queue. When this api is called, the data in the current cache queue will attempt to be reported.
 If the report succeeds, local cache data will be deleted.
 @param appId appId
 */
+ (void)flushWithAppId:(NSString * _Nullable)appId;

/**
 Switch reporting status
 @param status TDTrackStatus reporting status
 @param appId appId
 */
+ (void)setTrackStatus:(TDTrackStatus)status withAppId:(NSString * _Nullable)appId;

/**
 Track Events
 @param eventName event name
 @param appId appId
 */
+ (void)track:(NSString *)eventName withAppId:(NSString * _Nullable)appId;
/**
 Track Events
 @param eventName  event name
 @param properties event properties
 @param appId appId
 */
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties withAppId:(NSString * _Nullable)appId;
/**
 Track Events
 @param eventName event name
 @param properties event properties
 @param time event trigger time
 @param timeZone event trigger time time zone
 @param appId appId
 */
+ (void)track:(NSString *)eventName properties:(nullable NSDictionary *)properties time:(NSDate *)time timeZone:(NSTimeZone *)timeZone withAppId:(NSString * _Nullable)appId;
/**
 Track Events
 @param eventModel event Model
 @param appId appId
 */
+ (void)trackWithEventModel:(TDEventModel *)eventModel withAppId:(NSString * _Nullable)appId;
/**
 Timing Events
 Record the event duration, call this method to start the timing, stop the timing when the target event is uploaded, and add the attribute #duration to the event properties, in seconds.
 @param appId appId
 */
+ (void)timeEvent:(NSString *)eventName withAppId:(NSString * _Nullable)appId;


//MARK: user property

/**
 Sets the user property, replacing the original value with the new value if the property already exists.
 @param properties user properties
 @param appId appId
 */
+ (void)userSet:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId;
/**
 Sets a single user attribute, ignoring the new attribute value if the attribute already exists.
 @param properties user properties
 @param appId appId
 */
+ (void)userSetOnce:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId;
/**
 Reset single user attribute.
 @param propertyName user properties
 @param appId appId
 */
+ (void)userUnset:(NSString *)propertyName withAppId:(NSString * _Nullable)appId;
/**
 Reset user properties.
 @param propertyNames user properties
*/
+ (void)userUnsets:(NSArray<NSString *> *)propertyNames withAppId:(NSString * _Nullable)appId;
/**
 Adds the numeric type user attributes.
 @param properties user properties
 @param appId appId
 */
+ (void)userAdd:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId;
/**
 Adds the numeric type user attribute.
 @param propertyName  propertyName
 @param propertyValue propertyValue
 @param appId appId
 */
+ (void)userAddWithName:(NSString *)propertyName andValue:(NSNumber *)propertyValue withAppId:(NSString * _Nullable)appId;
/**
 Appends an element to a property of an array type.
 @param properties user properties
 @param appId appId
 */
+ (void)userAppend:(NSDictionary<NSString *, NSArray *> *)properties withAppId:(NSString * _Nullable)appId;
/**
 Appends an element to a property of an array type. It filters out elements that already exist.
 @param properties user properties
*/
+ (void)userUniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withAppId:(NSString * _Nullable)appId;
/**
 Delete the user attributes. This operation is not reversible and should be performed with caution.
 @param appId appId
 */
+ (void)userDeleteWithAppId:(NSString * _Nullable)appId;


//MARK: super property & preset property

/**
 Set the public event attribute, which will be included in every event uploaded after that. The public event properties are saved without setting them each time.
 @param properties super properties
 @param appId appId
 */
+ (void)setSuperProperties:(NSDictionary *)properties withAppId:(NSString * _Nullable)appId;
/**
 Clears a public event attribute.
 @param property property name
 @param appId appId
 */
+ (void)unsetSuperProperty:(NSString *)property withAppId:(NSString * _Nullable)appId;
/**
 Clear all public event attributes.
 @param appId appId
 */
+ (void)clearSuperPropertiesWithAppId:(NSString * _Nullable)appId;
/**
 Get the public event properties that have been set.
 
 @return super properties that have been set.
 @param appId appId
 */
+ (NSDictionary *)getSuperPropertiesWithAppId:(NSString * _Nullable)appId;
/**
 Set dynamic public properties. Each event uploaded after that will contain a public event attribute.
 @param propertiesHandler  propertiesHandler.
 @param appId appId
 */
+ (void)setDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))propertiesHandler withAppId:(NSString * _Nullable)appId;
/**
 Get the SDK's preset properties.
 
 @return preset property object
 @param appId appId
 */
+ (TDPresetProperties *)getPresetPropertiesWithAppId:(NSString * _Nullable)appId;

//MARK: error callback

/**
 Register TD error callback
 
 @param errorCallback code = 10001, ext = "string or json string", errorMsg = "error"
 @param appId appId
 */
+ (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback withAppId:(NSString * _Nullable)appId;


//MARK: custom property

/**
 Set the distinct ID to replace the default UUID distinct ID.
 @param distinctId distinctId
 @param appId appId
 */
+ (void)setDistinctId:(NSString *)distinctId withAppId:(NSString * _Nullable)appId;

/**
 Get distinct ID: The #distinct_id value in the reported data.
 
 @param appId appId
 @return distinctId
 */
+ (NSString *)getDistinctIdWithAppId:(NSString * _Nullable)appId;

/**
 Set the account ID. Each setting overrides the previous value. Login events will not be uploaded.
 @param accountId accountId
 @param appId appId
 */
+ (void)login:(NSString *)accountId withAppId:(NSString * _Nullable)appId;

/**
 Get account ID: The #account_id value in the reported data.
 
 @param appId appId
 @return accountId
 */
+ (NSString *)getAccountIdWithAppId:(NSString * _Nullable)appId;

/**
 Clearing the account ID will not upload user logout events.
 @param appId appId
 */
+ (void)logoutWithAppId:(NSString * _Nullable)appId;

/**
 Set the network conditions for uploading. By default, the SDK will set the network conditions as 3G, 4G and Wifi to upload data
 @param type network type
 @param appId appId
 */
+ (void)setUploadingNetworkType:(TDReportingNetworkType)type withAppId:(NSString * _Nullable)appId;

/// Format the time output in the format of SDK
/// @param date date
/// @param appId appId
/// @return date string
+ (NSString *)timeStringWithDate:(NSDate *)date withAppId:(NSString * _Nullable)appId;

#if TARGET_OS_IOS

/**
 Enable Auto-Tracking
 @param eventType Auto-Tracking type
 @param appId appId
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);
/**
 Enable auto tracking with super properties.
 @param eventType  Auto-Tracking type
 @param properties super properties
 @param appId appId
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

/**
 Enable the auto tracking function.
 @param eventType  Auto-Tracking type
 @param callback In the callback, eventType indicates the type of automatic collection, properties indicates the event properties before storage, and this block can return a dictionary for adding new properties
 @param appId appId
 */
+ (void)enableAutoTrack:(TDAutoTrackEventType)eventType callback:(NSDictionary *(^_Nullable)(TDAutoTrackEventType eventType, NSDictionary *properties))callback withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

/**
 Set and Update the value of a custom property for Auto-Tracking
 @param eventType  A list of TDAutoTrackEventType, indicating the types of automatic collection events that need to be enabled
 @param properties properties
 @param appId appId
 */
+ (void)setAutoTrackProperties:(TDAutoTrackEventType)eventType properties:(NSDictionary * _Nullable)properties withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

/**
 Ignore the Auto-Tracking of a UIViewController
 @param controllers Ignore the name of the UIViewController
 @param appId appId
 */
+ (void)ignoreAutoTrackViewControllers:(NSArray<NSString *> *)controllers withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

/**
 Ignore the Auto-Tracking  of click UIView
 @param aClass ignored UIView  Class
 @param appId appId
 */
+ (void)ignoreViewType:(Class)aClass withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

/**
 Dynamic super properties in  auto track  environment
 Set dynamic public properties for auto track event
 */
+ (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties withAppId:(NSString * _Nullable)appId API_UNAVAILABLE(macos);

#endif

@end

NS_ASSUME_NONNULL_END
