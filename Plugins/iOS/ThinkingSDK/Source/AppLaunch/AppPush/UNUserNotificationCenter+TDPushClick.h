
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UNUserNotificationCenter (TDPushClick)

- (void)thinkingdata_setDelegate:(id <UNUserNotificationCenterDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
