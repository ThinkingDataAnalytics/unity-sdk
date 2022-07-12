#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const VERSION;

@interface TDDeviceInfo : NSObject

+ (TDDeviceInfo *)sharedManager;


@property (nonatomic, copy) NSString *uniqueId;// 默认访客ID，一般是设备ID+安装次数组成
@property (nonatomic, copy) NSString *deviceId;// 设备id
@property (nonatomic, copy) NSString *appVersion;// app版本号
@property (nonatomic, readonly) BOOL isFirstOpen;// 是否是第一次启动
@property (nonatomic, copy) NSString *libName; // 库名称，外层库可以修改该字段
@property (nonatomic, copy) NSString *libVersion;// 库版本号，外层库可以修改该字段

+ (NSString *)libVersion;
+ (NSString*)bundleId;

- (void)td_updateData;
- (NSDictionary *)td_collectProperties;

+ (NSDate *)td_getInstallTime;

/// 获取属性
/// 注意线程问题
- (NSDictionary *)getAutomaticData;

@end

NS_ASSUME_NONNULL_END
