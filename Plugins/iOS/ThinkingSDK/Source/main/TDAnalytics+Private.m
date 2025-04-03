//
//  TDAnalytics+Private.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2024/5/31.
//

#import "TDAnalytics+Private.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDAnalytics (Private)

+ (void)trackDebug:(NSString *)eventName properties:(NSDictionary *)properties appId:(NSString * _Nullable)appId {
    if (appId == nil) {
        appId = [ThinkingAnalyticsSDK defaultAppId];
    }
    ThinkingAnalyticsSDK *teSDK = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    [teSDK innerTrackDebug:eventName properties:properties];
}

@end
