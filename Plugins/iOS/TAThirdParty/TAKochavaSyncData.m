//
//  TAKochavaSyncData.m
//  ThinkingSDK.default-Base-Core-Extension-Util-iOS
//
//  Created by wwango on 2022/9/28.
//

#import "TAKochavaSyncData.h"

@implementation TAKochavaSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSString *accountID = [taInstance getAccountId];
    NSString *distinctId = [taInstance getDistinctId];
    
    Class cls = NSClassFromString(@"KVATracker");
    SEL sel = NSSelectorFromString(@"shared");
    SEL sel1 = NSSelectorFromString(@"identityLink");
    SEL sel2 = NSSelectorFromString(@"registerWithNameString:identifierString:");
    if (cls && [cls respondsToSelector:sel]) {
        id shared = [cls performSelector:sel];
        if (shared && [shared respondsToSelector:sel1]) {
            id identityLink = [shared performSelector:sel1];
            if (identityLink && [identityLink respondsToSelector:sel2]) {
                [identityLink performSelector:sel2 withObject:TA_ACCOUNT_ID withObject:(accountID ? accountID : @"")];
                [identityLink performSelector:sel2 withObject:TA_DISTINCT_ID withObject:(distinctId ? distinctId : @"")];
            }
        }
    }
}
#pragma clang diagnostic pop


@end
