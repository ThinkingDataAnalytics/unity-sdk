#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const VERSION;

@interface TDDeviceInfo : NSObject

+ (TDDeviceInfo *)sharedManager;


@property (nonatomic, copy) NSString *uniqueId;// 默认访客ID，一般是设备ID+安装次数组成
@property (nonatomic, copy) NSString *deviceId;// 设备id
@property (nonatomic, copy) NSString *appVersion;

@property (nonatomic, readonly) BOOL isFirstOpen;

@property (nonatomic, copy) NSString *libName;
@property (nonatomic, copy) NSString *libVersion;
- (void)updateAutomaticData;

+ (NSString *)libVersion;
- (NSDictionary *)collectAutomaticProperties;
+ (NSString*)bundleId;
+ (NSDate *)td_getInstallTime;

/// 获取属性
/// 注意线程问题
- (NSDictionary *)getAutomaticData;

@end

NS_ASSUME_NONNULL_END
