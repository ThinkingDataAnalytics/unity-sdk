//
//  TDAutoTrackEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TDAutoTrackEvent.h"
#import "ThinkingAnalyticsSDKPrivate.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDAutoTrackEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];    
    // Reprocess the duration of automatic collection events, mainly app_start, app_end
    // app_start app_end events are collected by the automatic collection management class. There are the following problems: the automatic collection management class and the timeTracker event duration management class are processed by listening to appLifeCycle notifications, so they are not at a precise and unified time point. There will be small errors that need to be eliminated.
    // After testing, the error is less than 0.01s.
    CGFloat minDuration = 0.01;
    if (![TDCorePresetDisableConfig disableDuration]) {
        if (self.foregroundDuration > minDuration) {
            self.properties[@"#duration"] = @([NSString stringWithFormat:@"%.3f", self.foregroundDuration].floatValue);
        }
    }
    if (![TDCorePresetDisableConfig disableBackgroundDuration]) {
        if (self.backgroundDuration > minDuration) {
            self.properties[TD_BACKGROUND_DURATION] = @([NSString stringWithFormat:@"%.3f", self.backgroundDuration].floatValue);
        }
    }
    
    return dict;
}

- (TDAutoTrackEventType)autoTrackEventType {
    if ([self.eventName isEqualToString:TD_APP_START_EVENT]) {
        return TDAutoTrackEventTypeAppStart;
    } else if ([self.eventName isEqualToString:TD_APP_START_BACKGROUND_EVENT]) {
        return TDAutoTrackEventTypeAppStart;
    } else if ([self.eventName isEqualToString:TD_APP_END_EVENT]) {
        return TDAutoTrackEventTypeAppEnd;
    } else if ([self.eventName isEqualToString:TD_APP_VIEW_EVENT]) {
        return TDAutoTrackEventTypeAppViewScreen;
    } else if ([self.eventName isEqualToString:TD_APP_CLICK_EVENT]) {
        return TDAutoTrackEventTypeAppClick;
    } else if ([self.eventName isEqualToString:TD_APP_CRASH_EVENT]) {
        return TDAutoTrackEventTypeAppViewCrash;
    } else if ([self.eventName isEqualToString:TD_APP_INSTALL_EVENT]) {
        return TDAutoTrackEventTypeAppInstall;
    } else {
        return TDAutoTrackEventTypeNone;
    }
}

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TDPropertyValidator validateAutoTrackEventPropertyKey:key value:value error:error];
}

@end
