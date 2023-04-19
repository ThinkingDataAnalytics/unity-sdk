//
//  TAAutoPageViewEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/15.
//

#import "TAAutoPageViewEvent.h"
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAutoPageViewEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDPresetProperties disableScreenName]) {
        self.properties[@"#screen_name"] = self.screenName;
    }
    if (![TDPresetProperties disableTitle]) {
        self.properties[@"#title"] = self.pageTitle;
    }
    if (![TDPresetProperties disableUrl]) {
        self.properties[@"#url"] = self.pageUrl;
    }
    if (![TDPresetProperties disableReferrer]) {
        self.properties[@"#referrer"] = self.referrer;
    }
    return dict;
}

@end
