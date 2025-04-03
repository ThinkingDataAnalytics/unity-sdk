
#import "TDAppDelegateProxyManager.h"
#import "TDApplicationDelegateProxy.h"
#import "UIApplication+TDPushClick.h"
#import "TDLogging.h"

#if __has_include(<ThinkingDataCore/TDMethodHelper.h>)
#import <ThinkingDataCore/TDMethodHelper.h>
#else
#import "TDMethodHelper.h"
#endif

#if __has_include(<ThinkingDataCore/TDNewSwizzle.h>)
#import <ThinkingDataCore/TDNewSwizzle.h>
#else
#import "TDNewSwizzle.h"
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import "TDUNUserNotificationCenterDelegateProxy.h"
#endif

@implementation TDAppDelegateProxyManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static TDAppDelegateProxyManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[TDAppDelegateProxyManager alloc] init];
    });
    return manager;
}

- (void)proxyNotifications NS_EXTENSION_UNAVAILABLE_IOS(""){

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [TDMethodHelper swizzleRespondsToSelector];
        
        [TDApplicationDelegateProxy resolveOptionalSelectorsForDelegate:[UIApplication sharedApplication].delegate];
        [TDApplicationDelegateProxy proxyDelegate:[UIApplication sharedApplication].delegate selectors:[NSSet setWithArray:@[@"application:didReceiveLocalNotification:",
                                                                                                                             @"application:didReceiveRemoteNotification:fetchCompletionHandler:",
                                                                                                                             @"application:handleOpenURL:",
                                                                                                                             @"application:openURL:options:",
                                                                                                                             @"application:continueUserActivity:restorationHandler:",
                                                                                                                             @"application:performActionForShortcutItem:completionHandler:"]]];
        if (@available(iOS 10.0, *)) {
            if ([UNUserNotificationCenter currentNotificationCenter].delegate) {
                [TDUNUserNotificationCenterDelegateProxy resolveOptionalSelectorsForDelegate:[UNUserNotificationCenter currentNotificationCenter].delegate];
                [TDUNUserNotificationCenterDelegateProxy proxyDelegate:[UNUserNotificationCenter currentNotificationCenter].delegate selectors:[NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:",@"userNotificationCenter:willPresentNotification:withCompletionHandler:"]]];
            }
            NSError *error = NULL;
            [UNUserNotificationCenter td_new_swizzleMethod:@selector(setDelegate:) withMethod:@selector(thinkingdata_setDelegate:) error:&error];
            if (error) {
                TDLogInfo(@"proxy notification delegate error: %@", error);
            }
        }
    });
}

@end
