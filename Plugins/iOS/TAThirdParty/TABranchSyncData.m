//
//  TABranchSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/3/25.
//

#import "TABranchSyncData.h"

@implementation TABranchSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSString *accountID = [taInstance getAccountId];
    NSString *distinctId = [taInstance getDistinctId];
    
    Class cls = NSClassFromString(@"Branch");
    SEL sel1 = NSSelectorFromString(@"getInstance");
    SEL sel2 = NSSelectorFromString(@"setRequestMetadataKey:value:");
    if (cls && [cls respondsToSelector:sel1]) {
        id instance = [cls performSelector:sel1];
        if ([instance respondsToSelector:sel2]) {
            [instance performSelector:sel2 withObject:TA_ACCOUNT_ID withObject:accountID];
            [instance performSelector:sel2 withObject:TA_DISTINCT_ID withObject:distinctId];
        }
    }
}
#pragma clang diagnostic pop

@end
