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
#import <ThinkingDataCore/TDJSONUtil.h>
#import <ThinkingDataCore/NSData+TDGzip.h>
#import <ThinkingDataCore/NSDate+TDCore.h>
#import <ThinkingDataCore/TDNewSwizzle.h>
#import <ThinkingDataCore/TDClassHelper.h>
#import <ThinkingDataCore/TDMethodHelper.h>
#import <ThinkingDataCore/NSObject+TDSwizzle.h>
#import <ThinkingDataCore/TDSwizzler.h>
#import <ThinkingDataCore/TDOSLog.h>
#import <ThinkingDataCore/NSString+TDCore.h>
#import <ThinkingDataCore/TDApp.h>
#import <ThinkingDataCore/TDSettings.h>
#import <ThinkingDataCore/TDLogChannelProtocol.h>
#import <ThinkingDataCore/TDLogConstant.h>
#import <ThinkingDataCore/TDNotificationManager+Core.h>
#import <ThinkingDataCore/TDNotificationManager+Analytics.h>
#import <ThinkingDataCore/TDNotificationManager+Networking.h>
#import <ThinkingDataCore/TDNotificationManager+RemoteConfig.h>
#import <ThinkingDataCore/TDCoreDatabase.h>
#import <ThinkingDataCore/TDCalibratedTime.h>
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#import <ThinkingDataCore/NSObject+TDCore.h>
#import <ThinkingDataCore/NSURL+TDCore.h>
#import <ThinkingDataCore/NSNumber+TDCore.h>
#import <ThinkingDataCore/TDMediator+RemoteConfig.h>
#import <ThinkingDataCore/TDMediator+Analytics.h>
#import <ThinkingDataCore/TDMediator+Sensitive.h>
#import <ThinkingDataCore/TDCorePresetProperty.h>
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#import <ThinkingDataCore/NSDictionary+TDCore.h>
#import <ThinkingDataCore/TDCoreKeychainHelper.h>
#import <ThinkingDataCore/TDCoreLog.h>
#import <ThinkingDataCore/TDCoreWeakProxy.h>
#import <ThinkingDataCore/TDKeychainManager.h>
#import <ThinkingDataCore/TDLogChannelConsole.h>
#import <ThinkingDataCore/TDLogMessage.h>
#import <ThinkingDataCore/TDMediator.h>
#import <ThinkingDataCore/TDMediator+Strategy.h>
#import <ThinkingDataCore/TDNTPServer.h>
#import <ThinkingDataCore/TDNTPTypes.h>
#import <ThinkingDataCore/TDSettingsPrivate.h>
#else
#import "TDCoreInfo.h"
#import "TDJSONUtil.h"
#import "NSData+TDGzip.h"
#import "NSDate+TDCore.h"
#import "TDNewSwizzle.h"
#import "TDClassHelper.h"
#import "TDMethodHelper.h"
#import "NSObject+TDSwizzle.h"
#import "TDSwizzler.h"
#import "TDOSLog.h"
#import "NSString+TDCore.h"
#import "TDApp.h"
#import "TDLogConstant.h"
#import "TDSettings.h"
#import "TDLogChannelProtocol.h"
#import "TDNotificationManager+Core.h"
#import "TDNotificationManager+Analytics.h"
#import "TDNotificationManager+Networking.h"
#import "TDNotificationManager+RemoteConfig.h"
#import "TDCoreDatabase.h"
#import "TDCalibratedTime.h"
#import "TDCoreDeviceInfo.h"
#import "NSObject+TDCore.h"
#import "NSURL+TDCore.h"
#import "NSNumber+TDCore.h"
#import "TDMediator+RemoteConfig.h"
#import "TDMediator+Analytics.h"
#import "TDMediator+Sensitive.h"
#import "TDCorePresetProperty.h"
#import "TDCorePresetDisableConfig.h"
#import "NSDictionary+TDCore.h"
#import "TDCoreKeychainHelper.h"
#import "TDCoreLog.h"
#import "TDCoreWeakProxy.h"
#import "TDKeychainManager.h"
#import "TDLogChannelConsole.h"
#import "TDLogMessage.h"
#import "TDMediator.h"
#import "TDMediator+Strategy.h"
#import "TDNTPServer.h"
#import "TDNTPTypes.h"
#import "TDSettingsPrivate.h"
#endif



