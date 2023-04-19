//
//  TAAppEndEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TAAppEndEvent.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAppEndEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDPresetProperties disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName ?: @"";
    }
    
    return dict;
}

@end
