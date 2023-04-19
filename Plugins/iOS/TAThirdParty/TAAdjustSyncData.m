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
    SEL sel = NSSelectorFromString(@"addSessionCallbackParameter:value:");
    if (cls && [cls respondsToSelector:sel]) {
        [cls performSelector:sel withObject:TA_ACCOUNT_ID withObject:accountID];
        [cls performSelector:sel withObject:TA_DISTINCT_ID withObject:distinctId];
    }
}
#pragma clang diagnostic pop

@end
