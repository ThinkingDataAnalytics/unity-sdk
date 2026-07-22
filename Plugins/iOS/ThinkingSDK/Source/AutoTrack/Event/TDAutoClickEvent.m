//
//  TDAutoClickEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TDAutoClickEvent.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDAutoClickEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDCorePresetDisableConfig disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName;
    }
    if (![TDCorePresetDisableConfig disableElementId]) {
        self.properties[@"#element_id"] = self.elementId;
    }
    if (![TDCorePresetDisableConfig disableElementType]) {
        self.properties[@"#element_type"] = self.elementType;
    }
    if (![TDCorePresetDisableConfig disableElementContent]) {
        self.properties[@"#element_content"] = self.elementContent;
    }
    if (![TDCorePresetDisableConfig disableElementPosition]) {
        self.properties[@"#element_position"] = self.elementPosition;
    }
    if (![TDCorePresetDisableConfig disableTitle]) {
        self.properties[@"#title"] = self.pageTitle;
    }
    
    return dict;
}

@end
