//
//  ThinkingDataCore.h
//  ThinkingDataCore
//
//  Created by Hale on 2023/7/24.
//

#import <Foundation/Foundation.h>

// In this header, you should import all the public headers of your framework using statements like #import <ThinkingDataCore/PublicHeader.h>

#if __has_include(<ThinkingDataCore/TDCoreInfo.h>)
#import <ThinkingDataCore/TDCoreInfo.h>
#else
#import "TDCoreInfo.h"
#endif

#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif

#if __has_include(<ThinkingDataCore/NSData+TDGzip.h>)
#import <ThinkingDataCore/NSData+TDGzip.h>
#else
#import "NSData+TDGzip.h"
#endif

#if __has_include(<ThinkingDataCore/NSDate+TDCore.h>)
#import <ThinkingDataCore/NSDate+TDCore.h>
#else
#import "NSDate+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/TDNewSwizzle.h>)
#import <ThinkingDataCore/TDNewSwizzle.h>
#else
#import "TDNewSwizzle.h"
#endif

#if __has_include(<ThinkingDataCore/TDClassHelper.h>)
#import <ThinkingDataCore/TDClassHelper.h>
#else
#import "TDClassHelper.h"
#endif

#if __has_include(<ThinkingDataCore/TDMethodHelper.h>)
#import <ThinkingDataCore/TDMethodHelper.h>
#else
#import "TDMethodHelper.h"
#endif

#if __has_include(<ThinkingDataCore/NSObject+TDSwizzle.h>)
#import <ThinkingDataCore/NSObject+TDSwizzle.h>
#else
#import "NSObject+TDSwizzle.h"
#endif

#if __has_include(<ThinkingDataCore/TDSwizzler.h>)
#import <ThinkingDataCore/TDSwizzler.h>
#else
#import "TDSwizzler.h"
#endif

#if __has_include(<ThinkingDataCore/TDOSLog.h>)
#import <ThinkingDataCore/TDOSLog.h>
#else
#import "TDOSLog.h"
#endif

#if __has_include(<ThinkingDataCore/NSString+TDCore.h>)
#import <ThinkingDataCore/NSString+TDCore.h>
#else
#import "NSString+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/TDApp.h>)
#import <ThinkingDataCore/TDApp.h>
#else
#import "TDApp.h"
#endif

#if __has_include(<ThinkingDataCore/TDSettings.h>)
#import <ThinkingDataCore/TDSettings.h>
#else
#import "TDSettings.h"
#endif

#if __has_include(<ThinkingDataCore/TDLogChannelProtocol.h>)
#import <ThinkingDataCore/TDLogChannelProtocol.h>
#else
#import "TDLogChannelProtocol.h"
#endif

#if __has_include(<ThinkingDataCore/TDLogConstant.h>)
#import <ThinkingDataCore/TDLogConstant.h>
#else
#import "TDLogConstant.h"
#endif

#if __has_include(<ThinkingDataCore/TDNotificationManager+Core.h>)
#import <ThinkingDataCore/TDNotificationManager+Core.h>
#else
#import "TDNotificationManager+Core.h"
#endif

#if __has_include(<ThinkingDataCore/TDNotificationManager+Analytics.h>)
#import <ThinkingDataCore/TDNotificationManager+Analytics.h>
#else
#import "TDNotificationManager+Analytics.h"
#endif

#if __has_include(<ThinkingDataCore/TDNotificationManager+Networking.h>)
#import <ThinkingDataCore/TDNotificationManager+Networking.h>
#else
#import "TDNotificationManager+Networking.h"
#endif

#if __has_include(<ThinkingDataCore/TDNotificationManager+RemoteConfig.h>)
#import <ThinkingDataCore/TDNotificationManager+RemoteConfig.h>
#else
#import "TDNotificationManager+RemoteConfig.h"
#endif

#if __has_include(<ThinkingDataCore/TDCoreDatabase.h>)
#import <ThinkingDataCore/TDCoreDatabase.h>
#else
#import "TDCoreDatabase.h"
#endif

#if __has_include(<ThinkingDataCore/TDCalibratedTime.h>)
#import <ThinkingDataCore/TDCalibratedTime.h>
#else
#import "TDCalibratedTime.h"
#endif

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif

#if __has_include(<ThinkingDataCore/NSObject+TDCore.h>)
#import <ThinkingDataCore/NSObject+TDCore.h>
#else
#import "NSObject+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/NSURL+TDCore.h>)
#import <ThinkingDataCore/NSURL+TDCore.h>
#else
#import "NSURL+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/NSNumber+TDCore.h>)
#import <ThinkingDataCore/NSNumber+TDCore.h>
#else
#import "NSNumber+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/TDMediator+RemoteConfig.h>)
#import <ThinkingDataCore/TDMediator+RemoteConfig.h>
#else
#import "TDMediator+RemoteConfig.h"
#endif

#if __has_include(<ThinkingDataCore/TDMediator+Analytics.h>)
#import <ThinkingDataCore/TDMediator+Analytics.h>
#else
#import "TDMediator+Analytics.h"
#endif

#if __has_include(<ThinkingDataCore/TDMediator+Strategy.h>)
#import <ThinkingDataCore/TDMediator+Strategy.h>
#else
#import "TDMediator+Strategy.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetProperty.h>)
#import <ThinkingDataCore/TDCorePresetProperty.h>
#else
#import "TDCorePresetProperty.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif
