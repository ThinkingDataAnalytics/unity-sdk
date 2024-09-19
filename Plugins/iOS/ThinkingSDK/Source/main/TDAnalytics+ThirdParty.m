//
//  TDAnalytics+ThirdParty.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#import "TDAnalytics+ThirdParty.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDAnalytics (ThirdParty)

#if TARGET_OS_IOS

+ (void)enableThirdPartySharing:(TDThirdPartyType)type {
    [self enableThirdPartySharing:type properties:@{}];
}

+ (void)enableThirdPartySharing:(TDThirdPartyType)type properties:(NSDictionary<NSString *,NSObject *> *)properties {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    [self enableThirdPartySharing:type properties:properties withAppId:appId];
}

+ (void)enableThirdPartySharing:(TDThirdPartyType)type withAppId:(NSString *)appId {
    [self enableThirdPartySharing:type properties:@{} withAppId:appId];
}

+ (void)enableThirdPartySharing:(TDThirdPartyType)type properties:(NSDictionary<NSString *,NSObject *> *)properties withAppId:(NSString *)appId {
    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    
    if (instance != nil) {
        Class TARouterCls = NSClassFromString(@"TARouter");
        // com.thinkingdata://call.service/TAThirdPartyManager.TAThirdPartyProtocol/...?params={}(value url encode)
        NSURL *url = [NSURL URLWithString:@"com.thinkingdata://call.service.thinkingdata/TAThirdPartyManager.TAThirdPartyProtocol.enableThirdPartySharing:instance:property:/"];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
        if (TARouterCls && [TARouterCls respondsToSelector:@selector(canOpenURL:)] && [TARouterCls respondsToSelector:@selector(openURL:withParams:)]) {
            if ([TARouterCls performSelector:@selector(canOpenURL:) withObject:url]) {
                [TARouterCls performSelector:@selector(openURL:withParams:) withObject:url withObject:@{@"TAThirdPartyManager":@{@1:[NSNumber numberWithInteger:type],@2:instance,@3:(properties?:@{})}}];
            }
        }
    #pragma clang diagnostic pop
    }
}

#endif

@end
