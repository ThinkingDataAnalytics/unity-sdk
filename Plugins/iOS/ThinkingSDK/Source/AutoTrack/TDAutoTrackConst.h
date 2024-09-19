//
//  TDAutoTrackConst.h
//  Pods
//
//  Created by 杨雄 on 2023/7/23.
//

#ifndef TDAutoTrackConst_h
#define TDAutoTrackConst_h

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, TDAutoTrackEventType) {
    TDAutoTrackEventTypeNone = 0,
    TDAutoTrackEventTypeAppStart = 1 << 0,
    TDAutoTrackEventTypeAppEnd = 1 << 1,
    TDAutoTrackEventTypeAppClick = 1 << 2,
    TDAutoTrackEventTypeAppViewScreen = 1 << 3,
    TDAutoTrackEventTypeAppViewCrash = 1 << 4,
    TDAutoTrackEventTypeAppInstall = 1 << 5,
    TDAutoTrackEventTypeAll = TDAutoTrackEventTypeAppStart | TDAutoTrackEventTypeAppEnd | TDAutoTrackEventTypeAppClick | TDAutoTrackEventTypeAppInstall | TDAutoTrackEventTypeAppViewCrash | TDAutoTrackEventTypeAppViewScreen
};

static NSString * const TD_APP_START_EVENT                  = @"ta_app_start";
static NSString * const TD_APP_START_BACKGROUND_EVENT       = @"ta_app_bg_start";
static NSString * const TD_APP_END_EVENT                    = @"ta_app_end";
static NSString * const TD_APP_VIEW_EVENT                   = @"ta_app_view";
static NSString * const TD_APP_CLICK_EVENT                  = @"ta_app_click";
static NSString * const TD_APP_CRASH_EVENT                  = @"ta_app_crash";
static NSString * const TD_APP_INSTALL_EVENT                = @"ta_app_install";

#endif /* TDAutoTrackConst_h */
