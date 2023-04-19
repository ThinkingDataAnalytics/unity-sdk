//
//  TAFirebaseSyncData.m
//  ThinkingSDK.default-Base-Core-Extension-Util-iOS
//
//  Created by wwango on 2022/9/28.
//

#import "TAFirebaseSyncData.h"

@implementation TAFirebaseSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSString *distinctId = [taInstance getDistinctId] ? [taInstance getDistinctId] : @"";
    
    Class cls = NSClassFromString(@"FIRAnalytics");
    SEL sel = NSSelectorFromString(@"setUserID:");
    if (cls && [cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:distinctId];
    }

}
#pragma clang diagnostic pop

@end
