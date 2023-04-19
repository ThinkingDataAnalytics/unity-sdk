//
//  TAAppLovinSyncData.m
//  ThinkingSDK.default-Base-Core-Extension-Util-iOS
//
//  Created by wwango on 2022/9/28.
//

#import "TAAppLovinSyncData.h"

@implementation TAAppLovinSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
    NSString *distinctId = [taInstance getDistinctId] ? [taInstance getDistinctId] : @"";
    
    static dispatch_once_t onceToken;
    Class cls = NSClassFromString(@"ALSdk");
    SEL sel1 = NSSelectorFromString(@"shared");
    SEL sel2 = NSSelectorFromString(@"setUserIdentifier");
    __block id instance;
    dispatch_once(&onceToken, ^{
        if (cls && [cls respondsToSelector:sel1]) {
            instance = [cls performSelector:sel1];
            if ([instance respondsToSelector:sel2]) {
                [instance performSelector:sel2 withObject:distinctId];
            }
        }
    });
    

    if ([property isKindOfClass:[NSDictionary class]] && [property.allKeys containsObject:TASyncDataKey]) {
        id customData = property[TASyncDataKey];
        Class cls = NSClassFromString(@"MAAd");
        if ([customData isKindOfClass:cls]) {
            double revenue = [(NSNumber *)[customData performSelector:@selector(revenue)] doubleValue];
            NSString *networkName = [customData performSelector:@selector(networkName)];
            NSString *placement = [customData performSelector:@selector(placement)];
            NSString *adUnitId = [customData performSelector:@selector(adUnitIdentifier)];
            NSString *format  = [[customData performSelector:@selector(format)] performSelector:@selector(label)];
            NSString *countryCode = [instance valueForKeyPath:@"configuration.countryCode"];
            
            [taInstance track:@"appLovin_sdk_ad_revenue" properties:@{
                @"revenue":@(revenue),
                @"networkName":networkName,
                @"placement":placement,
                @"adUnitId":adUnitId,
                @"format":format,
                @"countryCode":countryCode}];
        }
    }
    
}
#pragma clang diagnostic pop

@end
