//
//  TDAppStartEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TDAppStartEvent.h"
#import <CoreGraphics/CoreGraphics.h>

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

static NSString * const TD_RESUME_FROM_BACKGROUND           = @"#resume_from_background";
static NSString * const TD_START_REASON                     = @"#start_reason";

@implementation TDAppStartEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDCorePresetDisableConfig disableResumeFromBackground]) {
        self.properties[TD_RESUME_FROM_BACKGROUND] = @(self.resumeFromBackground);
    }
    if (![TDCorePresetDisableConfig disableStartReason]) {
        self.properties[TD_START_REASON] = self.startReason;
    }
    
    return dict;
}

@end
