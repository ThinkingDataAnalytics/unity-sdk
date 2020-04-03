#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
Debug 模式

- ThinkingAnalyticsDebugOff : 默认不开启 Debug 模式
*/
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsDebugMode) {
    /**
     默认不开启 Debug 模式
     */
    ThinkingAnalyticsDebugOff      = 0,
    
    /**
     开启 Debug 模式，不入库
     */
    ThinkingAnalyticsDebugOnly     = 1 << 0,
    
    /**
     开启 Debug 模式，并入库
     */
    ThinkingAnalyticsDebug         = 1 << 1
};

/**
 证书验证模式
*/
typedef NS_OPTIONS(NSInteger, TDSSLPinningMode) {
    /**
     默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证
    */
    TDSSLPinningModeNone          = 0,
    
    /**
     校验证书的公钥
    */
    TDSSLPinningModePublicKey     = 1 << 0,
    
    /**
     校验证书的所有内容
    */
    TDSSLPinningModeCertificate   = 1 << 1
};

/**
 自定义 HTTPS 认证
*/
typedef NSURLSessionAuthChallengeDisposition (^TDURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *_Nullable __autoreleasing *_Nullable credential);

/**
 HTTPS 请求进行证书验证的策略
*/
@interface TDSecurityPolicy : NSObject

/**
 是否允许自建证书或者过期SSL证书，默认 NO
*/
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 是否验证证书域名，默认 YES
*/
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 自定义 HTTPS 认证
*/
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

/**
 证书验证模式
 
 @param pinningMode 证书验证模式
*/
+ (instancetype)policyWithPinningMode:(TDSSLPinningMode)pinningMode;

@end

/**
 TDConfig 是实例的配置类。通过 TDConfig 实例初始化 SDK，可以对 SDK 进行更灵活的配置。
 */
@interface TDConfig : NSObject

/**
 初始化配置后台自启事件 YES：采集后台自启事件 NO：不采集后台自启事件
 */
@property (nonatomic, assign) BOOL trackRelaunchedInBackgroundEvents;

/**
 初始化配置 Debug 模式
*/
@property (nonatomic, assign) ThinkingAnalyticsDebugMode debugMode;

/**
 初始化配置 launchOptions
*/
@property (nonatomic, copy) NSDictionary *launchOptions;

/**
 初始化配置证书校验策略
*/
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;

/**
 设置默认时区
*/
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

@end

/**
 ThinkingData API
 
 ## 初始化API
 
 ```objective-c
 ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL"];
 ```
 
 ## 事件埋点
 
 ```objective-c
 instance.track("some_event");
 ```
 或者
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstanceWithAppid:@"YOUR_APPID"] track:@"some_event"];
 ```
 如果项目中只有一个实例，也可以使用
 ```objective-c
 [[ThinkingAnalyticsSDK sharedInstance] track:@"some_event"];
 ```
 ## 详细文档
 http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation.html

 */
@interface ThinkingAnalyticsSDK : NSObject

#pragma mark - Tracking

/**
 获取实例

 @return SDK 实例
 */
+ (nullable ThinkingAnalyticsSDK *)sharedInstance;

/**
 根据 APPID 获取实例

 @param appid APP ID
 @return SDK 实例
 */
+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid;

/**
 初始化方法

 @param appId APP ID
 @param url 接收端地址
 @return SDK 实例
 */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;

/**
 初始化方法

 @param appId APP ID
 @param url 接收端地址
 @param config 初始化配置
 @return SDK实例
 */
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url withConfig:(nullable TDConfig *)config;

/**
 Log 级别

 - TDLoggingLevelNone : 默认不开启
 */
typedef NS_OPTIONS(NSInteger, TDLoggingLevel) {
    /**
     默认不开启
     */
    TDLoggingLevelNone  = 0,
    
    /**
     Error Log
     */
    TDLoggingLevelError = 1 << 0,
    
    /**
     Info  Log
     */
    TDLoggingLevelInfo  = 1 << 1,
    
    /**
     Debug Log
     */
    TDLoggingLevelDebug = 1 << 2,
};

/**
 上报数据网络条件

 - TDNetworkTypeDefault : 默认 3G、4G、WIFI
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    
    /**
     默认 3G、4G、WIFI
     */
    TDNetworkTypeDefault  = 0,
    
    /**
     仅WIFI
     */
    TDNetworkTypeOnlyWIFI = 1 << 0,
    
    /**
     2G、3G、4G、WIFI
     */
    TDNetworkTypeALL      = 1 << 1,
};

/**
 自动采集事件

 - ThinkingAnalyticsEventTypeNone           : 默认不开启自动埋点
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    
    /**
     默认不开启自动埋点
     */
    ThinkingAnalyticsEventTypeNone          = 0,
    
    /*
     APP 启动或从后台恢复事件
     */
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,
    
    /**
     APP 进入后台事件
     */
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,
    
    /**
     APP 控件点击事件
     */
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,
    
    /**
     APP 浏览页面事件
     */
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,
    
    /**
     APP 崩溃信息
     */
    ThinkingAnalyticsEventTypeAppViewCrash  = 1 << 4,
    
    /**
     APP 安装之后的首次打开
     */
    ThinkingAnalyticsEventTypeAppInstall    = 1 << 5
};

/**
 自定义事件埋点

 @param event         事件名称
 */
- (void)track:(NSString *)event;


/**
 自定义事件埋点

 @param event         事件名称
 @param propertieDict 事件属性
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;

/**
 自定义事件埋点

 @param event         事件名称
 @param propertieDict 事件属性
 @param time          事件触发时间
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time __attribute__((deprecated("使用 track:properties:time:timeZone: 方法传入")));

/**
 自定义事件埋点
 
 @param event         事件名称
 @param propertieDict 事件属性
 @param time          事件触发时间
 @param timeZone      事件触发时间时区
 */
- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict time:(NSDate *)time timeZone:(NSTimeZone *)timeZone;

/**
 记录事件时长

 @param event 事件名称
 */
- (void)timeEvent:(NSString *)event;

/**
 设置访客ID

 @param distinctId 访客 ID
 */
- (void)identify:(NSString *)distinctId;

/**
 获取访客ID

 @return 获取访客 ID
 */
- (NSString *)getDistinctId;

/**
 获取SDK版本号

 @return 获取 SDK 版本号
 */
+ (NSString *)getSDKVersion;

/**
 设置账号 ID

 @param accountId 账号 ID
 */
- (void)login:(NSString *)accountId;

/**
 清空账号 ID
 */
- (void)logout;

/**
 设置用户属性

 @param properties 用户属性
 */
- (void)user_set:(NSDictionary *)properties;

/**
 设置用户属性

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_set:(NSDictionary *)properties withTime:(NSDate *)time;

/**
 重置用户属性
 
 @param propertyName 用户属性
 */
- (void)user_unset:(NSString *)propertyName;

/**
 重置用户属性

 @param propertyName 用户属性
 @param time 事件触发时间
*/
- (void)user_unset:(NSString *)propertyName withTime:(NSDate *)time;

/**
 设置单次用户属性

 @param properties 用户属性
 */
- (void)user_setOnce:(NSDictionary *)properties;

/**
 设置单次用户属性

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_setOnce:(NSDictionary *)properties withTime:(NSDate *)time;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 */
- (void)user_add:(NSDictionary *)properties;

/**
 对数值类型用户属性进行累加操作

 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_add:(NSDictionary *)properties withTime:(NSDate *)time;

/**
  对数值类型用户属性进行累加操作

  @param propertyName  属性名称
  @param propertyValue 属性值
 */
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;

/**
 对数值类型用户属性进行累加操作

 @param propertyName  属性名称
 @param propertyValue 属性值
 @param time 事件触发时间
*/
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue withTime:(NSDate *)time;

/**
 删除用户 该操作不可逆 需慎重使用
 */
- (void)user_delete;

/**
 删除用户 该操作不可逆 需慎重使用
 
 @param time 事件触发时间
 */
- (void)user_delete:(NSDate *)time;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties;

/**
 对 Array 类型的用户属性进行追加操作
 
 @param properties 用户属性
 @param time 事件触发时间
*/
- (void)user_append:(NSDictionary<NSString *, NSArray *> *)properties withTime:(NSDate *)time;

/**
 设置公共事件属性

 @param properties 公共事件属性
 */
- (void)setSuperProperties:(NSDictionary *)properties;

/**
 清除一条公共事件属性

 @param property 公共事件属性名称
 */
- (void)unsetSuperProperty:(NSString *)property;

/**
 清除所有公共事件属性
 */
- (void)clearSuperProperties;

/**
 获取公共属性

 @return 公共事件属性
 */
- (NSDictionary *)currentSuperProperties;

/**
 设置动态公共属性

 @param dynamicSuperProperties 动态公共属性
 */
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void))dynamicSuperProperties;

/**
  设置上传的网络条件，默认情况下，SDK 将会网络条件为在 3G、4G 及 Wifi 时上传数据

 @param type 上传数据的网络类型
 */
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

/**
 开启自动采集事件功能

 @param eventType 枚举 ThinkingAnalyticsAutoTrackEventType 的列表，表示需要开启的自动采集事件类型
 
 详细文档 http://doc.thinkingdata.cn/tgamanual/installation/ios_sdk_installation/ios_sdk_autotrack.html
 */
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;

/**
 获取设备 ID

 @return 设备 ID
 */
- (NSString *)getDeviceId;

/**
 忽略某个页面的自动采集事件

 @param controllers 忽略 UIViewController 的名称
 */
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;

/**
 忽略某个类型控件的点击事件

 @param aClass 忽略的控件 Class
 */
- (void)ignoreViewType:(Class)aClass;

/**
 H5 与原生 APP SDK 打通，配合 addWebViewUserAgent 接口使用

 @param webView 需要打通H5的控件
 @param request NSURLRequest 网络请求
 @return YES：处理此次请求 NO：未处理此次请求
 
 详细文档 http://doc.thinkingdata.cn/tgamanual/installation/h5_app_integrate.html
 */
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request;

/**
 与 H5 打通数据时需要调用此接口配置 UserAgent
 */
- (void)addWebViewUserAgent;

/**
 开启 Log 功能

 @param level 打印日志级别
 */
+ (void)setLogLevel:(TDLoggingLevel)level;

/**
 上报数据
 */
- (void)flush;

/**
 暂停/开启上报

 @param enabled YES：开启上报 NO：暂停上报
 */
- (void)enableTracking:(BOOL)enabled;

/**
 停止上报，后续的上报和设置都无效，数据将清空
 */
- (void)optOutTracking;

/**
 停止上报，后续的上报和设置都无效，数据将清空，并且发送 user_del
 */
- (void)optOutTrackingAndDeleteUser;

/**
 允许上报
 */
- (void)optInTracking;

/**
 创建轻实例

 @return SDK 实例
 */
- (ThinkingAnalyticsSDK *)createLightInstance;

/**
 使用指定NTP Server 校准时间
 @param ntpServer NTP Server
*/
+ (void)calibrateTimeWithNtp:(NSString *)ntpServer;

/**
 校准时间
 
 @param timestamp 当前时间戳，单位毫秒
*/
+ (void)calibrateTime:(NSTimeInterval)timestamp;

- (NSString *)getTimeString:(NSDate *)date;

@end

#pragma mark - Autotrack View Interface

/**
 APP 控件点击事件
 */
@interface UIView (ThinkingAnalytics)

/**
设置控件元素 ID
 */
@property (copy,nonatomic) NSString *thinkingAnalyticsViewID;

/**
 配置 APPID 的控件元素 ID
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewIDWithAppid;

/**
 忽略某个控件的点击事件
 */
@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;

/**
 配置 APPID 的忽略某个控件的点击事件
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsIgnoreViewWithAppid;

/**
 自定义控件点击事件的属性
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewProperties;

/**
 配置 APPID 的自定义控件点击事件的属性
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewPropertiesWithAppid;

/**
 thinkingAnalyticsDelegate
 */
@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;

@end

#pragma mark - Autotrack View Protocol

/**
 自动埋点设置属性
 */
@protocol TDUIViewAutoTrackDelegate

@optional

/**
 UITableView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UITableView 事件属性
 
 @return 事件属性
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 UICollectionView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalytics_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UICollectionView 事件属性

 @return 事件属性
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 页面自动埋点
 */
@protocol TDAutoTracker

@optional

/**
 自定义页面浏览事件的属性

 @return 事件属性
 */
- (NSDictionary *)getTrackProperties;

/**
 配置 APPID 自定义页面浏览事件的属性

 @return 事件属性
 */
- (NSDictionary *)getTrackPropertiesWithAppid;

@end

/**
 页面自动埋点
 */
@protocol TDScreenAutoTracker <TDAutoTracker>

@optional

/**
 自定义页面浏览事件的属性

 @return 预置属性 #url 的值
 */
- (NSString *)getScreenUrl;

/**
 配置 APPID 自定义页面浏览事件的属性

 @return 预置属性 #url 的值
 */
- (NSDictionary *)getScreenUrlWithAppid;

@end

NS_ASSUME_NONNULL_END
