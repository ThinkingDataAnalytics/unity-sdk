//
//  TAAdjustSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/3/25.
//

#import "TAAdjustSyncData.h"

@implementation TAAdjustSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSString *accountID = [taInstance getAccountId] ? [taInstance getAccountId] : @"";
    NSString *distinctId = [taInstance getDistinctId] ? [taInstance getDistinctId] : @"";
    
    Class cls = NSClassFromString(@"Adjust");
    SEL selectorV4 = NSSelectorFromString(@"addSessionCallbackParameter:value:");
    SEL selectorV5 = NSSelectorFromString(@"addGlobalCallbackParameter:forKey:");
    if (cls != nil) {
        if ([cls respondsToSelector:selectorV4]) {
            [cls performSelector:selectorV4 withObject:TA_ACCOUNT_ID withObject:accountID];
            [cls performSelector:selectorV4 withObject:TA_DISTINCT_ID withObject:distinctId];
        } else if ([cls respondsToSelector:selectorV5]) {
            [cls performSelector:selectorV5 withObject:accountID withObject:TA_ACCOUNT_ID];
            [cls performSelector:selectorV5 withObject:distinctId withObject:TA_DISTINCT_ID];
        }
    }
}
#pragma clang diagnostic pop

@end
