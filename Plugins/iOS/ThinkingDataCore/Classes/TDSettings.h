//
//  TDSettings.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TDSDKMode) {
    TDSDKModeNomal = 0,
    TDSDKModeDebug,
    TDSDKModeDebugOnly,
};

@interface TDSettings : NSObject

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *serverUrl;
@property (nonatomic, copy) NSString *instanceName;
@property (nonatomic, assign) TDSDKMode mode;
@property (nonatomic, assign) BOOL enableLog;
/// Set default time zone.
/// You can use this time zone to compare the offset of the current time zone and the default time zone
@property (nonatomic, strong) NSTimeZone *defaultTimeZone;
@property (nonatomic, assign) NSInteger encryptVersion;
@property (nonatomic, copy) NSString *encryptKey;
@property (nonatomic, assign) BOOL enableAutoPush;
@property (nonatomic, assign) BOOL enableAutoCalibrated;
@property (nonatomic, strong) NSDictionary<NSString *, NSObject *> *rccFetchParams;

@end

NS_ASSUME_NONNULL_END
