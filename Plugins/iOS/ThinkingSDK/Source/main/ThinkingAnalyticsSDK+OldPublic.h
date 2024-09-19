//
//  ThinkingAnalyticsSDK+OldPublic.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/10.
//

#if __has_include(<ThinkingSDK/ThinkingAnalyticsSDK.h>)
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#else
#import "ThinkingAnalyticsSDK.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingAnalyticsSDK (OldPublic)

//MARK: SDK info

+ (void)calibrateTimeWithNtp:(NSString *)ntpServer DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics calibrateTimeWithNtp:]");
+ (void)calibrateTime:(NSTimeInterval)timestamp DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics calibrateTime:]");
+ (nullable NSString *)getLocalRegion DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getLocalRegion]");
/**
 Set Log level
 @param level log level
 */
+ (void)setLogLevel:(TDLoggingLevel)level DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableLog:]");
+ (void)setCustomerLibInfoWithLibName:(NSString *)libName libVersion:(NSString *)libVersion DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setCustomerLibInfoWithLibName:libVersion:]");
/**
 Get sdk version
 
 @return version string
 */
+ (NSString *)getSDKVersion DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getSDKVersion]");
/**
 Get DeviceId
 
 @return deviceId
 */
+ (NSString *)getDeviceId DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getDeviceId]");
/**
 Format the time output in the format of SDK
 @param date date
 @return date string
 */
+ (NSString *)timeStringWithDate:(NSDate *)date DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics timeStringWithDate:]");

#pragma mark - Tracking

/**
 Initialization method
 After the SDK initialization is complete, the saved instance can be obtained through this api

 @param appId appId
 @param url server url
 @return sdk instance
 */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics startAnalyticsWithAppId:(NSString *)appId serverUrl:(NSString *)url]");

/**
 Initialization method
 After the SDK initialization is complete, the saved instance can be obtained through this api

 @param config initialization configuration
 @return sdk instance
 */
+ (ThinkingAnalyticsSDK *)startWithConfig:(nullable TDConfig *)config DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics startAnalyticsWithConfig:(nullable TDConfig *)config]");

/**
  Initialization method
  After the SDK initialization is complete, the saved instance can be obtained through this api

  @param appId appId
  @param url server url
  @param config initialization configuration object
  @return one instance
  */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(nullable TDConfig *)config DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics startAnalyticsWithConfig:(nullable TDConfig *)config]");

/**
 Get default instance

 @return SDK instance
 */
+ (nullable ThinkingAnalyticsSDK *)sharedInstance DEPRECATED_MSG_ATTRIBUTE("Deprecated. please use class method [TDAnalytics ...]");

/**
  Get one instance according to appid or instanceName

  @param appid APP ID or instanceName
  @return SDK instance
  */
+ (nullable ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid DEPRECATED_MSG_ATTRIBUTE("Deprecated. please use class method [TDAnalytics ...withAppId:(NSString *)appId]");

#pragma mark - Action Track

/**
 Track Events

 @param event         event name
 */
- (void)track:(NSString *)event DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics track:]");

/**
 Track Events

 @param event         event name
 @param propertieDict event properties
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics track:properties:]");

/**
 Track Events

 @param event         event name
 @param propertieDict event properties
 @param time          event trigger time
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics track:properties:time:timeZone:]");

/**
 Track Events
 
  @param event event name
  @param propertieDict event properties
  @param time event trigger time
  @param timeZone event trigger time time zone
  */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time timeZone:(NSTimeZone *)timeZone DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics track:properties:time:timeZone:]");

/**
 Track Events
 
  @param eventModel event Model
  */
- (void)trackWithEventModel:(TDEventModel *)eventModel DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics trackWithEventModel]");

/**
 Get the events collected in the App Extension and report them
 
  @param appGroupId The app group id required for data sharing
  */
- (void)trackFromAppExtensionWithAppGroupId:(NSString *)appGroupId DEPRECATED_MSG_ATTRIBUTE("Deprecated");

#pragma mark -

/**
 Timing Events
 Record the event duration, call this method to start the timing, stop the timing when the target event is uploaded, and add the attribute #duration to the event properties, in seconds.
 */
- (void)timeEvent:(NSString *)event DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics timeEvent:]");

/**
 Identify
 Set the distinct ID to replace the default UUID distinct ID.
 */
- (void)identify:(NSString *)distinctId DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setDistinctId:]");

/**
 Get Distinctid
 Get a visitor ID: The #distinct_id value in the reported data.
 */
- (NSString *)getDistinctId DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getDistinctId]");

/**
 Login
 Set the account ID. Each setting overrides the previous value. Login events will not be uploaded.

 @param accountId account ID
 */
- (void)login:(NSString *)accountId DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics login:]");

/**
 Logout
 Clearing the account ID will not upload user logout events.
 */
- (void)logout DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics logout]");

/**
 User_Set
 Sets the user property, replacing the original value with the new value if the property already exists.

 @param properties user properties
 */
- (void)user_set:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userSet:]");

/**
 User_Set

 @param properties user properties
 @param time event trigger time
*/
- (void)user_set:(NSDictionary *)properties withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userSet:]");

/**
 User_Unset
 
 @param propertyName user properties
 */
- (void)user_unset:(NSString *)propertyName DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userUnset:]");

/**
 User_Unset
 Reset user properties.

 @param propertyName user properties
 @param time event trigger time
*/
- (void)user_unset:(NSString *)propertyName withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userUnset:]");

/**
 User_SetOnce
 Sets a single user attribute, ignoring the new attribute value if the attribute already exists.

 @param properties user properties
 */
- (void)user_setOnce:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userSetOnce:]");

/**
 User_SetOnce

 @param properties user properties
 @param time event trigger time
*/
- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userSetOnce:]");

/**
 User_Add
 Adds the numeric type user attributes.

 @param properties user properties
 */
- (void)user_add:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAdd:]");

/**
 User_Add

 @param properties user properties
 @param time event trigger time
*/
- (void)user_add:(NSDictionary *)properties withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAdd:]");

/**
 User_Add

  @param propertyName  propertyName
  @param propertyValue propertyValue
 */
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAddWithName:andValue:]");

/**
 User_Add

 @param propertyName  propertyName
 @param propertyValue propertyValue
 @param time event trigger time
*/
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAddWithName:andValue:]");

/**
 User_Delete
 Delete the user attributes,This operation is not reversible and should be performed with caution.
 */
- (void)user_delete DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userDelete]");

/**
 User_Delete
 
 @param time event trigger time
 */
- (void)user_delete:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userDelete]");

/**
 User_Append
 Append a user attribute of the List type.
 
 @param properties user properties
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAppend:]");

/**
 User_Append
 The element appended to the library needs to be done to remove the processing,and then import.
 
 @param properties user properties
 @param time event trigger time
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userAppend:]");

/**
 User_UniqAppend
 
 @param properties user properties
*/
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userUniqAppend:]");

/**
 User_UniqAppend
 
 @param properties user properties
 @param time event trigger time
*/
- (void)user_uniqAppend:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate * _Nullable)time DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics userUniqAppend:]");


/**
 Static Super Properties
 Set the public event attribute, which will be included in every event uploaded after that. The public event properties are saved without setting them each time.
  *
 */
- (void)setSuperProperties:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setSuperProperties:]");

/**
 Unset Super Property
 Clears a public event attribute.
 */
- (void)unsetSuperProperty:(NSString *)property DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics unsetSuperProperty:]");

/**
 Clear Super Properties
 Clear all public event attributes.
 */
- (void)clearSuperProperties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics clearSuperProperties]");

/**
 Get Static Super Properties
 Gets the public event properties that have been set.
 */
- (NSDictionary *)currentSuperProperties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getSuperProperties]");

/**
 Dynamic super properties
 Set dynamic public properties. Each event uploaded after that will contain a public event attribute.
 */
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setDynamicSuperProperties:]");

/**
 Register TD error callback
 
 @param errorCallback
 code = 10001,
 ext = "string or json string",
 errorMsg = "error"
 */
- (void)registerErrorCallback:(void(^)(NSInteger code, NSString * _Nullable errorMsg, NSString * _Nullable ext))errorCallback DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics registerErrorCallback:]");

/**
 Gets prefabricated properties for all events.
 */
- (TDPresetProperties *)getPresetProperties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getSuperProperties]");

/**
 Set the network conditions for uploading. By default, the SDK will set the network conditions as 3G, 4G and Wifi to upload data
 */
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setUploadingNetworkType:]");

#if TARGET_OS_IOS

/**
 Enable Auto-Tracking

 @param eventType Auto-Tracking type
 
 detailed documentation http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation/ios_sdk_autotrack.html
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableAutoTrack:]");

/**
 Enable the auto tracking function.

 @param eventType  Auto-Tracking type
 @param properties properties
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableAutoTrack:properties:]");

/**
 Enable the auto tracking function.

 @param eventType  Auto-Tracking type
 @param callback callback
 In the callback, eventType indicates the type of automatic collection, properties indicates the event properties before storage, and this block can return a dictionary for adding new properties
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType callback:(NSDictionary *(^)(ThinkingAnalyticsAutoTrackEventType eventType, NSDictionary *properties))callback DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableAutoTrack:callback:]");

/**
 Set and Update the value of a custom property for Auto-Tracking
 
 @param eventType  A list of ThinkingAnalyticsAutoTrackEventType, indicating the types of automatic collection events that need to be enabled
 @param properties properties
 */
- (void)setAutoTrackProperties:(ThinkingAnalyticsAutoTrackEventType)eventType properties:(NSDictionary *)properties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setAutoTrackProperties:]");

/**
 Ignore the Auto-Tracking of a page

 @param controllers Ignore the name of the UIViewController
 */
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics ignoreAutoTrackViewControllers:]");

/**
 Ignore the Auto-Tracking  of click event

 @param aClass ignored controls  Class
 */
- (void)ignoreViewType:(Class)aClass DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics ignoreViewType:]");

/**
 Dynamic super properties in  auto track  environment.
 Set dynamic public properties for auto track event
 */
- (void)setAutoTrackDynamicProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setAutoTrackDynamicProperties:]");

#endif

//MARK: -

/**
 Get DeviceId
 */
- (NSString *)getDeviceId DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics getDeviceId]");

/**
 Empty the cache queue. When this api is called, the data in the current cache queue will attempt to be reported.
 If the report succeeds, local cache data will be deleted.
 */
- (void)flush DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics flush]");

/**
 Switch reporting status

 @param status TDTrackStatus reporting status
 */
- (void)setTrackStatus:(TATrackStatus)status DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setTrackStatus:]");

- (void)enableTracking:(BOOL)enabled DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setTrackStatus:]");
- (void)optOutTracking DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setTrackStatus:]");
- (void)optOutTrackingAndDeleteUser DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setTrackStatus:]");
- (void)optInTracking DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics setTrackStatus:]");

/**
 Create a light instance
 */
- (ThinkingAnalyticsSDK *)createLightInstance DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics lightInstanceIdWithAppId] and [TDAnalytics ...withAppId:(NSString *)appId]");

- (NSString *)getTimeString:(NSDate *)date DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics timeStringWithDate:]");

#if TARGET_OS_IOS
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableThirdPartySharing:]");
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type customMap:(NSDictionary<NSString *, NSObject *> *)customMap DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics enableThirdPartySharing:properties:]");
#endif

/// Deprecated. replace with: +showUpWebView:withRequest:
/// @param webView webView
/// @param request NSURLRequest
/// @return YES：Process this request NO: This request has not been processed
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics showUpWebView:withRequest:]");

/// Deprecated. replace with: +addWebViewUserAgent
- (void)addWebViewUserAgent DEPRECATED_MSG_ATTRIBUTE("Deprecated. replace with: [TDAnalytics addWebViewUserAgent]");

@end

NS_ASSUME_NONNULL_END
