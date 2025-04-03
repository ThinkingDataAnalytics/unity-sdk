//
//  TDCoreDeviceInfo.h
//  Pods
//
//  Created by 杨雄 on 2024/4/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCoreDeviceInfo : NSObject

+ (NSTimeInterval)bootTime;
+ (NSString *)manufacturer;
+ (nullable NSString *)systemLanguage;
+ (NSString *)bundleId;
+ (NSString *)deviceId;
+ (NSDate *)installTime;
+ (NSString *)ram;
+ (NSString *)disk;
+ (NSString *)appVersion;
+ (NSString *)os;
+ (NSString *)osVersion;
+ (NSString *)deviceModel;
+ (NSString *)deviceType;
+ (BOOL)isSimulator;

#if TARGET_OS_IOS
+ (NSNumber *)fps;
+ (NSNumber *)screenWidth;
+ (NSNumber *)screenHeight;
+ (NSString *)networkType;
+ (nullable NSString *)carrier;
#endif

@end

NS_ASSUME_NONNULL_END
