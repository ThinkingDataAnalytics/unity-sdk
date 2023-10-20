
#import "TDUNUserNotificationCenterDelegateProxy.h"
#import "TDClassHelper.h"
#import "NSObject+TDDelegateProxy.h"
#import <objc/message.h>
#import "TDAPPPushParams.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDAppLaunchReason.h"
#import "TDCommonUtil.h"

@implementation TDUNUserNotificationCenterDelegateProxy

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    SEL selector = @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:);
    [TDUNUserNotificationCenterDelegateProxy invokeWithTarget:self selector:selector, center, response, completionHandler];
    [TDUNUserNotificationCenterDelegateProxy trackEventWithTarget:self notificationCenter:center notificationResponse:response];
}

+ (void)trackEventWithTarget:(NSObject *)target notificationCenter:(UNUserNotificationCenter *)center notificationResponse:(UNNotificationResponse *)response  API_AVAILABLE(ios(10.0)){

    if (target != center.delegate) {
        return;
    }

    if (![TDPresetProperties disableStartReason]) {
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
    
    if (![TDPresetProperties disableOpsReceiptProperties]) {
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
    return [NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:"]];
}

@end
