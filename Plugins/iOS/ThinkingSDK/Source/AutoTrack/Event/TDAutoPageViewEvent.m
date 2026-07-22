//
//  TDAutoPageViewEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TDAutoPageViewEvent.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDAutoPageViewEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDCorePresetDisableConfig disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName;
    }
    if (![TDCorePresetDisableConfig disableTitle]) {
        self.properties[@"#title"] = self.pageTitle;
    }
    if (![TDCorePresetDisableConfig disableUrl]) {
        self.properties[@"#url"] = self.pageUrl;
    }
    if (![TDCorePresetDisableConfig disableReferrer]) {
        self.properties[@"#referrer"] = self.referrer;
    }
    return dict;
}

@end
