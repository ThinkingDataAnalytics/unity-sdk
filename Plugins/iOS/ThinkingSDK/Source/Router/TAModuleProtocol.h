//
//  TAModuleProtocol.h
//  ThinkingSDK.default-Base-Core-Extension-Router-Util-iOS
//
//  Created by wwango on 2022/10/7.
//

#import <Foundation/Foundation.h>

#define TA_EXPORT_MODULE(isAsync) \
+ (void)load { [[TAModuleManager sharedManager] registerDynamicModule:[self class]]; } \
-(BOOL)async { return [[NSString stringWithUTF8String:#isAsync] boolValue];}

@class TAContext;


NS_ASSUME_NONNULL_BEGIN

@protocol TAModuleProtocol <NSObject>

@optional

- (void)basicModuleLevel;

- (NSInteger)modulePriority;

- (BOOL)async;

- (void)modSetUp:(TAContext *)context;

- (void)modInit:(TAContext *)context;

- (void)modSplash:(TAContext *)context;

- (void)modQuickAction:(TAContext *)context;

- (void)modTearDown:(TAContext *)context;

- (void)modWillResignActive:(TAContext *)context;

- (void)modDidEnterBackground:(TAContext *)context;

- (void)modWillEnterForeground:(TAContext *)context;

- (void)modDidBecomeActive:(TAContext *)context;

- (void)modWillTerminate:(TAContext *)context;

- (void)modUnmount:(TAContext *)context;

- (void)modOpenURL:(TAContext *)context;

- (void)modDidReceiveMemoryWaring:(TAContext *)context;

- (void)modDidFailToRegisterForRemoteNotifications:(TAContext *)context;

- (void)modDidRegisterForRemoteNotifications:(TAContext *)context;

- (void)modDidReceiveRemoteNotification:(TAContext *)context;

- (void)modDidReceiveLocalNotification:(TAContext *)context;

- (void)modWillPresentNotification:(TAContext *)context;

- (void)modDidReceiveNotificationResponse:(TAContext *)context;

- (void)modWillContinueUserActivity:(TAContext *)context;

- (void)modContinueUserActivity:(TAContext *)context;

- (void)modDidFailToContinueUserActivity:(TAContext *)context;

- (void)modDidUpdateContinueUserActivity:(TAContext *)context;

- (void)modHandleWatchKitExtensionRequest:(TAContext *)context;

- (void)modDidCustomEvent:(TAContext *)context;

@end

NS_ASSUME_NONNULL_END
