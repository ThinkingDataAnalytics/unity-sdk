
#import "UNUserNotificationCenter+TDPushClick.h"
#import "TDUNUserNotificationCenterDelegateProxy.h"

@implementation UNUserNotificationCenter (TDPushClick)

- (void)thinkingdata_setDelegate:(id<UNUserNotificationCenterDelegate>)delegate {
    
    [TDUNUserNotificationCenterDelegateProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self thinkingdata_setDelegate:delegate];
    if (!self.delegate) {
        return;
    }
    [TDUNUserNotificationCenterDelegateProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:", @"userNotificationCenter:willPresentNotification:withCompletionHandler:"]]];
}

@end
