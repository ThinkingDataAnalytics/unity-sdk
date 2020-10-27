#import <Foundation/Foundation.h>
#import "TDConstant.h"
#import "TDSecurityPolicy.h"
NS_ASSUME_NONNULL_BEGIN



@interface TDConfig:NSObject <NSCopying>
/**
 设置自动埋点类型
 */
@property (assign, nonatomic) ThinkingAnalyticsAutoTrackEventType autoTrackEventType;
/**
 数据发送的网络环境
 */
@property (assign, nonatomic) ThinkingNetworkType networkTypePolicy;
/**
 数据上传间隔时间
 */
@property (nonatomic) NSNumber *uploadInterval;
/**
 当有数据上传时,数据缓存的条数达到uploadsize时,立即上传数据
 */
@property (nonatomic) NSNumber *uploadSize;
/**
 事件黑名单,不进行统计的事件名称添加到此处
 */
@property (strong, nonatomic) NSArray *disableEvents;
/**
 最多缓存事件条数
 */
@property (class,  nonatomic) NSInteger maxNumEvents;
/**
 数据缓存过期时间,最长为10天
 */
@property (class,  nonatomic) NSInteger expirationDays;
/**
 应用的唯一appid
 */
@property (atomic, copy) NSString *appid;
/**
 数据上传的服务器地址
 */
@property (atomic, copy) NSString *configureURL;

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
 可以使用该时区,对比当前时间所在时区和默认时区的offset
*/
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

+ (TDConfig *)defaultTDConfig;
- (void)updateConfig;
- (void)setNetworkType:(ThinkingAnalyticsNetworkType)type;

@end
NS_ASSUME_NONNULL_END
