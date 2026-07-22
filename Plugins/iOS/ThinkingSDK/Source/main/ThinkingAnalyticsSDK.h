#import <Foundation/Foundation.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>

#if __has_include(<ThinkingSDK/TDAutoTrackPublicHeader.h>)
#import <ThinkingSDK/TDAutoTrackPublicHeader.h>
#else
#import "TDAutoTrackPublicHeader.h"
#endif

#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>

#endif

#if __has_include(<ThinkingSDK/TDFirstEventModel.h>)
#import <ThinkingSDK/TDFirstEventModel.h>
#else
#import "TDFirstEventModel.h"
#endif

#if __has_include(<ThinkingSDK/TDEditableEventModel.h>)
#import <ThinkingSDK/TDEditableEventModel.h>
#else
#import "TDEditableEventModel.h"
#endif


#if __has_include(<ThinkingSDK/TDConfig.h>)
#import <ThinkingSDK/TDConfig.h>
#else
#import "TDConfig.h"
#endif

#if __has_include(<ThinkingSDK/TDPresetProperties.h>)
#import <ThinkingSDK/TDPresetProperties.h>
#else
#import "TDPresetProperties.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface ThinkingAnalyticsSDK : NSObject


@end

NS_ASSUME_NONNULL_END
