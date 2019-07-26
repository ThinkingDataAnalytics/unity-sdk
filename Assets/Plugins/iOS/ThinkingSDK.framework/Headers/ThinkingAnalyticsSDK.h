#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ThinkingAnalyticsSDK : NSObject

// 获取实例
+ (nullable ThinkingAnalyticsSDK *)sharedInstance;
+ (ThinkingAnalyticsSDK *)sharedInstanceWithAppid:(NSString *)appid;

// 初始化方法
+ (ThinkingAnalyticsSDK *)startWithAppId:(NSString *)appId withUrl:(NSString *)url;

// Log级别
typedef NS_OPTIONS(NSInteger, TDLoggingLevel) {
    TDLoggingLevelNone  = 0,        // 默认 不开启
    TDLoggingLevelError = 1 << 0,   // Error Log
    TDLoggingLevelInfo  = 1 << 1,   // Info Log
    TDLoggingLevelDebug = 1 << 2,   // Debug Log
};

// 上报数据网络条件
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    TDNetworkTypeDefault  = 0,       // 默认 3G、4G、WIFI
    TDNetworkTypeOnlyWIFI = 1 << 0,  // 仅WIFI
    TDNetworkTypeALL      = 1 << 1,  // 2G、3G、4G、WIFI
};

// 自动采集事件
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    ThinkingAnalyticsEventTypeNone          = 0,        // 默认 不开启自动埋点
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,   // APP启动或从后台恢复事件
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,   // APP进入后台事件
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,   // APP浏览页面事件
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,   // APP点击控件事件
    ThinkingAnalyticsEventTypeAppViewCrash  = 1 << 4    // APP崩溃信息
};

// 自定义事件埋点
- (void)track:(NSString *)event;
- (void)track:(NSString *)event properties:(NSDictionary *)propertieDict;
- (void)track:(NSString *)event properties:(NSDictionary *)propertieDict time:(NSDate *)time;

// 记录事件时长
- (void)timeEvent:(NSString *)event;

// 设置访客ID
- (void)identify:(NSString *)distinctId;

// 获取访客ID
- (NSString *)getDistinctId;

// 设置账号ID
- (void)login:(NSString *)accountId;

// 清空账号ID
- (void)logout;

// 设置用户属性
- (void)user_set:(NSDictionary *)property;

// 设置单次用户属性
- (void)user_setOnce:(NSDictionary *)property;

// 对数值类型用户属性进行累加操作
- (void)user_add:(NSDictionary *)property;
- (void)user_add:(NSString *)propertyName andPropertyValue:(NSNumber *)propertyValue;

// 删除用户属性
- (void)user_delete;

// 设置公共事件属性
- (void)setSuperProperties:(NSDictionary *)propertyDict;
// 清除一条公共事件属性
- (void)unsetSuperProperty:(NSString *)property;
// 清除所有公共事件属性
- (void)clearSuperProperties;
// 获取公共属性
- (NSDictionary *)currentSuperProperties;

// 设置动态公共属性
- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^)(void)) dynamicSuperProperties;

// 设置上传的网络条件，默认情况下，SDK 将会网络条件为在 3G、4G 及 Wifi 时上传数据
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

// 开启自动采集事件功能
- (void)enableAutoTrack:(ThinkingAnalyticsAutoTrackEventType)eventType;

// 获取设备ID
- (NSString *)getDeviceId;

// 忽略某个页面的自动采集事件
- (void)ignoreAutoTrackViewControllers:(NSArray *)controllers;

// 忽略某个类型控件的点击事件
- (void)ignoreViewType:(Class)aClass;

// 支持 H5 与原生 APP SDK 打通
- (BOOL)showUpWebView:(id)webView WithRequest:(NSURLRequest *)request;
- (void)addWebViewUserAgent;

// 开启Log功能
+ (void)setLogLevel:(TDLoggingLevel)level;

// 上报数据
- (void)flush;

@end

@interface UIView (ThinkingAnalytics)

- (nullable UIViewController *)viewController;

// 设置控件元素ID
@property (copy,nonatomic) NSString* thinkingAnalyticsViewID;
@property (strong,nonatomic) NSDictionary* thinkingAnalyticsViewIDWithAppid;

// 忽略某个控件的点击事件
@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;
@property (strong,nonatomic) NSDictionary* thinkingAnalyticsIgnoreViewWithAppid;

// 自定义控件点击事件的属性
@property (strong,nonatomic) NSDictionary* thinkingAnalyticsViewProperties;
@property (strong,nonatomic) NSDictionary* thinkingAnalyticsViewPropertiesWithAppid;

@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;

@end

@protocol TDUIViewAutoTrackDelegate

// UITableView 事件属性
@optional
-(NSDictionary *) thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;
-(NSDictionary *) thinkingAnalyticsWithAppid_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

// UICollectionView 事件属性
@optional
-(NSDictionary *) thinkingAnalytics_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;
-(NSDictionary *) thinkingAnalyticsWithAppid_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol TDAutoTracker

// 自定义页面浏览事件的属性
@optional
-(NSDictionary *)getTrackProperties;
-(NSDictionary *)getTrackPropertiesWithAppid;

@end


@protocol TDScreenAutoTracker<TDAutoTracker>

// 自定义页面浏览事件的属性
@optional
-(NSString *) getScreenUrl;
-(NSDictionary *) getScreenUrlWithAppid;

@end

NS_ASSUME_NONNULL_END
