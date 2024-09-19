//
//  TAModuleManager.h
//  Pods
//
//  Created by wwango on 2022/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TAModuleLevel)
{
    TAModuleBasic  = 0,
    TAModuleNormal = 1
};

typedef NS_ENUM(NSInteger, TAModuleEventType)
{
    TAMSetupEvent = 0,
    TAMInitEvent,
    TAMTearDownEvent,
    TAMSplashEvent,
    TAMQuickActionEvent,
    TAMWillResignActiveEvent,
    TAMDidEnterBackgroundEvent,
    TAMWillEnterForegroundEvent,
    TAMDidBecomeActiveEvent,
    TAMWillTerminateEvent,
    TAMUnmountEvent,
    TAMOpenURLEvent,
    TAMDidReceiveMemoryWarningEvent,
    TAMDidFailToRegisterForRemoteNotificationsEvent,
    TAMDidRegisterForRemoteNotificationsEvent,
    TAMDidReceiveRemoteNotificationEvent,
    TAMDidReceiveLocalNotificationEvent,
    TAMWillPresentNotificationEvent,
    TAMDidReceiveNotificationResponseEvent,
    TAMWillContinueUserActivityEvent,
    TAMContinueUserActivityEvent,
    TAMDidFailToContinueUserActivityEvent,
    TAMDidUpdateUserActivityEvent,
    TAMDidCustomEvent = 1000
    
};

@interface TAModuleManager : NSObject

+ (instancetype)sharedManager;

// If you do not comply with set Level protocol, the default Normal
- (void)registerDynamicModule:(Class)moduleClass;

- (void)unRegisterDynamicModule:(Class)moduleClass;

- (void)loadLocalModules;

- (void)registedAllModules;

- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr;

- (void)triggerEvent:(NSInteger)eventType;

- (void)triggerEvent:(NSInteger)eventType withCustomParam:(NSDictionary * _Nullable)customParam;


@end

NS_ASSUME_NONNULL_END
