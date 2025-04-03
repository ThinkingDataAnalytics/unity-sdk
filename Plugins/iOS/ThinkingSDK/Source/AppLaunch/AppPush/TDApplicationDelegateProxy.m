
#import "TDApplicationDelegateProxy.h"
#import "NSObject+TDDelegateProxy.h"
#import "UIApplication+TDPushClick.h"
#import <objc/message.h>
#import "TDAppLaunchReason.h"
#import "TDCommonUtil.h"
#import "TDLogging.h"

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


@implementation TDApplicationDelegateProxy

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    SEL selector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
    [TDApplicationDelegateProxy invokeWithTarget:self selector:selector, application, userInfo, completionHandler];
    [TDApplicationDelegateProxy trackEventWithTarget:self application:application remoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification API_DEPRECATED("Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]", ios(4.0, 10.0)) {
    SEL selector = @selector(application:didReceiveLocalNotification:);
    [TDApplicationDelegateProxy invokeWithTarget:self selector:selector, application, notification];
    [TDApplicationDelegateProxy trackEventWithTarget:self application:application localNotification:notification];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    SEL selector = @selector(application:continueUserActivity:restorationHandler:);
    if (![TDCorePresetDisableConfig disableStartReason])  {
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": [TDCommonUtil string: userActivity.webpageURL.absoluteString],@"data":@{}};
    }
    return [TDApplicationDelegateProxy invokeReturnBOOLWithTarget:self selector:selector arg1:application arg2:userActivity arg3:restorationHandler];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    SEL selector = @selector(application:openURL:options:);
    if (![TDCorePresetDisableConfig disableStartReason])  {
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": [TDCommonUtil string:url.absoluteString],@"data":@{}};
    }
    return [TDApplicationDelegateProxy invokeReturnBOOLWithTarget:self selector:selector arg1:app arg2:url arg3:options];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    SEL selector = @selector(application:handleOpenURL:);
    if (![TDCorePresetDisableConfig disableStartReason])  {
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": [TDCommonUtil string:url.absoluteString], @"data":@{}};
    }
    return [TDApplicationDelegateProxy invokeReturnBOOLWithTarget:self selector:selector arg1:application arg2:url];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler API_AVAILABLE(ios(9.0)){
    SEL selector = @selector(application:performActionForShortcutItem:completionHandler:);
    [TDApplicationDelegateProxy invokeWithTarget:self selector:selector, application, shortcutItem, completionHandler];
    if (![TDCorePresetDisableConfig disableStartReason])  {
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"",@"data": [TDCommonUtil dictionary:shortcutItem.userInfo]};
    }
}


+ (void)trackEventWithTarget:(NSObject *)target application:(UIApplication *)application remoteNotification:(NSDictionary *)userInfo {
    
    if (target != application.delegate) {
        return;
    }

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        TDLogInfo(@"iOS version >= 10.0, callback for %@ was ignored.", @"application:didReceiveRemoteNotification:fetchCompletionHandler:");
        return;
    }
    
    if (application.applicationState != UIApplicationStateInactive) {
        return;
    }
    
    if (![TDCorePresetDisableConfig disableStartReason])  {
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"", @"data": [TDCommonUtil dictionary:userInfo]};
    }

}

+ (void)trackEventWithTarget:(NSObject *)target application:(UIApplication *)application localNotification:(UILocalNotification *)notification API_DEPRECATED("Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]", ios(4.0, 10.0)){

    if (target != application.delegate) {
        return;
    }

    BOOL isValidPushClick = NO;
    if (application.applicationState == UIApplicationStateInactive) {
        isValidPushClick = YES;
    }
    
    if (!isValidPushClick) {
        return;
    }
    
    if (![TDCorePresetDisableConfig disableStartReason]) {
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        properties[@"alertBody"] = notification.alertBody;
        if (@available(iOS 8.2, *)) {
            properties[@"alertTitle"] = notification.alertTitle;
        }
        [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
        [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"", @"data": [TDCommonUtil dictionary:properties]};
    }
}

+ (NSSet<NSString *> *)optionalSelectors {
    return [NSSet setWithArray:@[@"application:didReceiveLocalNotification:",
                                  @"application:didReceiveRemoteNotification:fetchCompletionHandler:",
                                  @"application:handleOpenURL:",
                                  @"application:openURL:options:",
                                  @"application:continueUserActivity:restorationHandler:",
                                  @"application:performActionForShortcutItem:completionHandler:"]];
}

@end
