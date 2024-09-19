#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const VERSION;

@interface TDDeviceInfo : NSObject

+ (TDDeviceInfo *)sharedManager;


@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, readonly) BOOL isFirstOpen;
@property (nonatomic, copy) NSString *libName;
@property (nonatomic, copy) NSString *libVersion;

+ (NSString *)libVersion;
+ (NSString*)bundleId;

- (void)td_updateData;
- (NSDictionary *)td_collectProperties;

+ (NSDate *)td_getInstallTime;

- (NSDictionary *)getAutomaticData;

+ (NSString *)currentRadio;

@end

NS_ASSUME_NONNULL_END
