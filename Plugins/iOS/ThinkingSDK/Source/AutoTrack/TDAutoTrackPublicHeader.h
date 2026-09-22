//
//  TDAutoTrackPublicHeader.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#ifndef TDAutoTrackPublicHeader_h
#define TDAutoTrackPublicHeader_h

#if __has_include(<ThinkingSDK/TDAutoTrackProtocol.h>)
#import <ThinkingSDK/TDAutoTrackProtocol.h>
#else
#import "TDAutoTrackProtocol.h"
#endif

#if __has_include(<ThinkingSDK/UIView+ThinkingAnalytics.h>)
#import <ThinkingSDK/UIView+ThinkingAnalytics.h>
#else
#import "UIView+ThinkingAnalytics.h"
#endif

#if __has_include(<ThinkingSDK/TDAutoTrackConst.h>)
#import <ThinkingSDK/TDAutoTrackConst.h>
#else
#import "TDAutoTrackConst.h"
#endif

#endif /* TDAutoTrackPublicHeader_h */
