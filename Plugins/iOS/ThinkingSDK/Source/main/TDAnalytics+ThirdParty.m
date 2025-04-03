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
        Class TAThirdPartyManager = NSClassFromString(@"TAThirdPartyManager");
        if (TAThirdPartyManager == nil) {
            return;
        }
        NSObject *manager = [[TAThirdPartyManager alloc] init];
        if (manager == nil) {
            return;
        }
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        SEL action = @selector(enableThirdPartySharing:instance:property:);
#pragma clang diagnostic pop

        NSMethodSignature *methodSig = [manager methodSignatureForSelector:action];
        if (methodSig == nil) {
            return;
        }
        
        @try {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
            
            NSNumber *thirdPartyTypeNumber = [NSNumber numberWithInteger:type];
            [invocation setArgument:&thirdPartyTypeNumber atIndex:2];
            
            [invocation setArgument:&instance atIndex:3];
            
            NSDictionary *thirdPartyProperties = properties;
            [invocation setArgument:&thirdPartyProperties atIndex:4];

            [invocation setSelector:action];
            [invocation setTarget:manager];
            [invocation invoke];
        } @catch (NSException *exception) {
            TDLogError(@"ThirdParty invocate failed!")
        }
    }
}

#endif

@end
