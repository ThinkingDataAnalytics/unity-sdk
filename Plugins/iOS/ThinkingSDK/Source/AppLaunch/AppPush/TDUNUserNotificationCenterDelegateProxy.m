
#import "TDUNUserNotificationCenterDelegateProxy.h"

#if __has_include(<ThinkingDataCore/TDClassHelper.h>)
#import <ThinkingDataCore/TDClassHelper.h>
#else
#import "TDClassHelper.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

#import "NSObject+TDDelegateProxy.h"
#import <objc/message.h>
#import "TDAPPPushParams.h"
#import "TDAppLaunchReason.h"
#import "TDCommonUtil.h"
#import "ThinkingAnalyticsSDK.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDUNUserNotificationCenterDelegateProxy

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
    [TDUNUserNotificationCenterDelegateProxy invokeWithTarget:self selector:selector, center, response, completionHandler];
    [TDUNUserNotificationCenterDelegateProxy trackEventWithTarget:self notificationCenter:center notificationResponse:response];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    SEL selector = @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:);
    [TDUNUserNotificationCenterDelegateProxy invokeWithTarget:self selector:selector, center, notification, completionHandler];
    [TDUNUserNotificationCenterDelegateProxy trackEventWithTarget:self notificationCenter:center notification:notification];
}

+ (void)trackEventWithTarget:(NSObject *)target notificationCenter:(UNUserNotificationCenter *)center notification:(UNNotification *)notification  API_AVAILABLE(ios(10.0)){
    
}

+ (void)trackEventWithTarget:(NSObject *)target notificationCenter:(UNUserNotificationCenter *)center notificationResponse:(UNNotificationResponse *)response  API_AVAILABLE(ios(10.0)){

    if (target != center.delegate) {
        return;
    }

    if (![TDCorePresetDisableConfig disableStartReason]) {
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        NSDictionary *userInfo = __td_get_userNotificationCenterResponse(response);
        if (userInfo) {
            [properties addEntriesFromDictionary:userInfo];
        }
        properties[@"title"] = __td_get_userNotificationCenterRequestContentTitle(response);
        properties[@"body"] = __td_get_userNotificationCenterRequestContentBody(response);
        
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"", @"data": [TDCommonUtil dictionary:properties]};
    }
    
    if ([ThinkingAnalyticsSDK defaultInstance].config.enableAutoPush) {
        @try {
            if ([response isKindOfClass:[NSClassFromString(@"UNNotificationResponse") class]]) {
                NSDictionary *userInfo = [response valueForKeyPath:@"notification.request.content.userInfo"];
                [TDAppLaunchReason td_ops_push_click:userInfo];
            }
        } @catch (NSException *exception) {
            
        }
    }
    
}

+ (NSSet<NSString *> *)optionalSelectors {
    return [NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", @"userNotificationCenter:willPresentNotification:withCompletionHandler:"]];
}

@end
