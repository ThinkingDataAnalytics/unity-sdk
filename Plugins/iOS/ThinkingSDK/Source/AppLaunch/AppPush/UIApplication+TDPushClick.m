
#import "UIApplication+TDPushClick.h"
#import "TDApplicationDelegateProxy.h"
#import <objc/runtime.h>

static void *const kSALaunchOptions = (void *)&kSALaunchOptions;

@implementation UIApplication (TDPushClick)

- (void)thinkingdata_setDelegate:(id<UIApplicationDelegate>)delegate {
    [TDApplicationDelegateProxy resolveOptionalSelectorsForDelegate:delegate];
    
    [self thinkingdata_setDelegate:delegate];
    
    if (!self.delegate) {
        return;
    }
    [TDApplicationDelegateProxy proxyDelegate:self.delegate selectors:[NSSet setWithArray:@[@"application:didReceiveLocalNotification:", @"application:didReceiveRemoteNotification:fetchCompletionHandler:"]]];
}

- (NSDictionary *)thinkingdata_launchOptions {
    return objc_getAssociatedObject(self, kSALaunchOptions);
}

- (void)setThinkingdata_launchOptions:(NSDictionary *)thinkingdata_launchOptions {
    objc_setAssociatedObject(self, kSALaunchOptions, thinkingdata_launchOptions, OBJC_ASSOCIATION_COPY);
}

@end
