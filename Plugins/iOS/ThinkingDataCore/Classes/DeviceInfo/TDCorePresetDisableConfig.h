//
//  TDCorePresetDisableConfig.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCorePresetDisableConfig : NSObject

@property(class, nonatomic, readonly) BOOL disableOpsReceiptProperties;
@property(class, nonatomic, readonly) BOOL disableStartReason;
@property(class, nonatomic, readonly) BOOL disableDisk;
@property(class, nonatomic, readonly) BOOL disableRAM;
@property(class, nonatomic, readonly) BOOL disableFPS;
@property(class, nonatomic, readonly) BOOL disableSimulator;
@property(class, nonatomic, readonly) BOOL disableAppVersion;
@property(class, nonatomic, readonly) BOOL disableOsVersion;
@property(class, nonatomic, readonly) BOOL disableManufacturer;
@property(class, nonatomic, readonly) BOOL disableDeviceModel;
@property(class, nonatomic, readonly) BOOL disableScreenHeight;
@property(class, nonatomic, readonly) BOOL disableScreenWidth;
@property(class, nonatomic, readonly) BOOL disableCarrier;
@property(class, nonatomic, readonly) BOOL disableDeviceId;
@property(class, nonatomic, readonly) BOOL disableSystemLanguage;
@property(class, nonatomic, readonly) BOOL disableLib;
@property(class, nonatomic, readonly) BOOL disableLibVersion;
@property(class, nonatomic, readonly) BOOL disableBundleId;
@property(class, nonatomic, readonly) BOOL disableOs;
@property(class, nonatomic, readonly) BOOL disableInstallTime;
@property(class, nonatomic, readonly) BOOL disableDeviceType;
@property(class, nonatomic, readonly) BOOL disableSessionID;
@property(class, nonatomic, readonly) BOOL disableCalibratedTime;

@property(class, nonatomic, readonly) BOOL disableNetworkType;
@property(class, nonatomic, readonly) BOOL disableZoneOffset;
@property(class, nonatomic, readonly) BOOL disableDuration;
@property(class, nonatomic, readonly) BOOL disableBackgroundDuration;
@property(class, nonatomic, readonly) BOOL disableAppCrashedReason;
@property(class, nonatomic, readonly) BOOL disableResumeFromBackground;
@property(class, nonatomic, readonly) BOOL disableElementId;
@property(class, nonatomic, readonly) BOOL disableElementType;
@property(class, nonatomic, readonly) BOOL disableElementContent;
@property(class, nonatomic, readonly) BOOL disableElementPosition;
@property(class, nonatomic, readonly) BOOL disableElementSelector;
@property(class, nonatomic, readonly) BOOL disableScreenName;
@property(class, nonatomic, readonly) BOOL disableTitle;
@property(class, nonatomic, readonly) BOOL disableUrl;
@property(class, nonatomic, readonly) BOOL disableReferrer;

@end

NS_ASSUME_NONNULL_END
