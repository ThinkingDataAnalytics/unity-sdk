//
//  TAAppStartEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/17.
//

#import "TAAppStartEvent.h"
#import <CoreGraphics/CoreGraphics.h>
#import "TDPresetProperties+TDDisProperties.h"

@implementation TAAppStartEvent

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    if (![TDPresetProperties disableResumeFromBackground]) {
        self.properties[@"#resume_from_background"] = @(self.resumeFromBackground);
    }
    if (![TDPresetProperties disableStartReason]) {
        self.properties[@"#start_reason"] = self.startReason;
    }
    
    return dict;
}

@end
