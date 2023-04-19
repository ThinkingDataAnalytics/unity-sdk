//
//  TAAutoClickEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TAAutoClickEvent.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAutoClickEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDPresetProperties disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName;
    }
    if (![TDPresetProperties disableElementId]) {
        self.properties[@"#element_id"] = self.elementId;
    }
    if (![TDPresetProperties disableElementType]) {
        self.properties[@"#element_type"] = self.elementType;
    }
    if (![TDPresetProperties disableElementContent]) {
        self.properties[@"#element_content"] = self.elementContent;
    }
    if (![TDPresetProperties disableElementPosition]) {
        self.properties[@"#element_position"] = self.elementPosition;
    }
    if (![TDPresetProperties disableTitle]) {
        self.properties[@"#title"] = self.pageTitle;
    }
    
    return dict;
}

@end
