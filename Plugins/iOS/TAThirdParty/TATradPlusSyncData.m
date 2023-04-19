//
//  TATradPlusSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/3/25.
//

#import "TATradPlusSyncData.h"

@implementation TATradPlusSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSMutableDictionary * datas = [NSMutableDictionary dictionaryWithDictionary:property];
//    NSString *accountID = [taInstance getAccountId];
    NSString *distinctId = [taInstance getDistinctId];
//    [datas setObject:(accountID ? accountID : @"") forKey:TA_ACCOUNT_ID];
    [datas setObject:distinctId ? distinctId : @"" forKey:TA_DISTINCT_ID];
    
    Class cls = NSClassFromString(@"TradPlus");
    SEL sel1 = NSSelectorFromString(@"sharedInstance");
    SEL sel2 = NSSelectorFromString(@"setDicCustomValue:");
    if (cls && [cls respondsToSelector:sel1]) {
        id instance = [cls performSelector:sel1];
        if ([instance respondsToSelector:sel2]) {
            [instance performSelector:sel2 withObject:datas];
        }
    }
}
#pragma clang diagnostic pop

@end
