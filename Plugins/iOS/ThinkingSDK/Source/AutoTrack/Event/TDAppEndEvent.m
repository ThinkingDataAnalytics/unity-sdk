//
//  TDAppEndEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TDAppEndEvent.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDAppEndEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDCorePresetDisableConfig disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName ?: @"";
    }
    
    return dict;
}

@end
