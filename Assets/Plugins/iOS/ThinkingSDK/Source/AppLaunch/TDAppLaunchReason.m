//
//  TDAppLaunchReason.m
//  ThinkingSDK
//
//  Created by wwango on 2021/11/17.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAppLaunchReason.h"
#import <objc/runtime.h>
#import "NSObject+TDUtil.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDCommonUtil.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

#define td_force_inline __inline__ __attribute__((always_inline))

static td_force_inline void __td_td_swizzleWithOriSELStr(id target, NSString *oriSELStr, SEL newSEL, IMP newIMP) {
    SEL origSEL = NSSelectorFromString(oriSELStr);
    Method origMethod = class_getInstanceMethod([target class], origSEL);
    
    if ([target respondsToSelector:origSEL]) {
        // 给当前类添加新方法(newSEL, newIMP)
        class_addMethod([target class], newSEL, newIMP, method_getTypeEncoding(origMethod));
        
        // 获取原始方法实现，方法实现可能是当前类，也可能是父类
        Method origMethod = class_getInstanceMethod([target class], origSEL);
        // 新方法实现
        Method newMethod = class_getInstanceMethod([target class], newSEL);
        
        // 判断当前类是否实现原始方法
        if(class_addMethod([target class], origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            // 当前类没有实现原始方法，父类实现了原始方法
            // 给当前类添加原始方法(origSEL, newIMP)，调用class_replaceMethod后，当前类的新方法和原始方法的IMP交换了
            // 不会污染父类
            class_replaceMethod([target class], newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        } else {
            // 当前类实现了原始方法，只会交换当前类，不会污染父类
            method_exchangeImplementations(origMethod, newMethod);
        }
    } else {
        // 类和父类都没有实现，给当前类添加新方法，不会污染父类
        class_addMethod([target class], origSEL, newIMP, method_getTypeEncoding(origMethod));
    }
}


@implementation TDAppLaunchReason

+ (void)load {
    
    // 是否需要采集启动原因
    [TDPresetProperties disPresetProperties];
    if ([TDPresetProperties disableStartReason]) return;
    
    [self td_hookUserNotificationCenterMethod];

    [[NSNotificationCenter defaultCenter] addObserver:[TDAppLaunchReason sharedInstance]
                                             selector:@selector(_applicationDidFinishLaunchingNotification:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:[TDAppLaunchReason sharedInstance]
                                             selector:@selector(_applicationDidEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
}

+ (void)td_hookUserNotificationCenterMethod {
    if (@available(iOS 10.0, *)) {
        // 要求推送的代理需要在application:didFinishLaunchingWithOptions:设置
        // 如果不是在application:didFinishLaunchingWithOptions:设置，那么冷启动时推送的消息会收集不到
        if ([UNUserNotificationCenter currentNotificationCenter].delegate) {
            NSString *pushSel = @"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:";
            SEL newpushSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", pushSel]);
            IMP newpushSelIMP = imp_implementationWithBlock(^(id _self1, UNUserNotificationCenter *center, UNNotificationResponse *response, id completionHandler) {
                if ([_self1 respondsToSelector:newpushSel]) {
                    [NSObject performSelector:newpushSel onTarget:_self1 withArguments:@[center, response, completionHandler]];
                }
                
                
                NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
                UNNotificationRequest *request = response.notification.request;
                NSDictionary *userInfo = request.content.userInfo;
                if (userInfo) {
                    [properties addEntriesFromDictionary:userInfo];
                }
                properties[@"title"] = request.content.title;
                properties[@"body"] = request.content.body;
                
                [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
                [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"",
                                             @"data": [TDCommonUtil dictionary:properties]};
            });
            __td_td_swizzleWithOriSELStr([UNUserNotificationCenter currentNotificationCenter].delegate, pushSel, newpushSel, newpushSelIMP);
        } else {
            
            NSString *pushDelegateSel = @"setDelegate:";
            SEL newPushDelegateSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", pushDelegateSel]);
            IMP newPushDelegateIMP = imp_implementationWithBlock(^(id _self, id delegate) {
                if ([_self respondsToSelector:newPushDelegateSel]) {
                    [NSObject performSelector:newPushDelegateSel onTarget:_self withArguments:@[delegate]];
                }
                
                
                NSString *pushSel = @"userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:";
                SEL newpushSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", pushSel]);
                IMP newpushSelIMP = imp_implementationWithBlock(^(id _self1, UNUserNotificationCenter *center, UNNotificationResponse *response, id completionHandler) {
                    if ([_self1 respondsToSelector:newpushSel]) {
                        [NSObject performSelector:newpushSel onTarget:_self1 withArguments:@[center, response, completionHandler]];
                    }
                    
                    
                    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
                    UNNotificationRequest *request = response.notification.request;
                    NSDictionary *userInfo = request.content.userInfo;
                    if (userInfo) {
                        [properties addEntriesFromDictionary:userInfo];
                    }
                    properties[@"title"] = request.content.title;
                    properties[@"body"] = request.content.body;
                    
                    [[TDAppLaunchReason sharedInstance] clearAppLaunchParams];
                    [TDAppLaunchReason sharedInstance].appLaunchParams = @{@"url": @"",
                                                 @"data": [TDCommonUtil dictionary:properties]};
                });
                __td_td_swizzleWithOriSELStr([UNUserNotificationCenter currentNotificationCenter].delegate, pushSel, newpushSel, newpushSelIMP);
            });
            __td_td_swizzleWithOriSELStr([UNUserNotificationCenter currentNotificationCenter], pushDelegateSel, newPushDelegateSel, newPushDelegateIMP);
        }
    }
}

+ (TDAppLaunchReason *)sharedInstance {
    static dispatch_once_t onceToken;
    static TDAppLaunchReason *appLaunchManager;
    
    dispatch_once(&onceToken, ^{
        appLaunchManager = [TDAppLaunchReason new];
    });
    
    return appLaunchManager;
}

- (void)clearAppLaunchParams {
    self.appLaunchParams = @{@"url":@"",
                             @"data":@{}};
}

- (void)_applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self clearAppLaunchParams];
}

// 拦截冷启动和热启动的参数
- (void)_applicationDidFinishLaunchingNotification:(NSNotification *)notification {
    
    __weak TDAppLaunchReason *weakSelf = self;
    
    NSDictionary *launchOptions = notification.userInfo;
    NSString *url = [self getInitDeeplink:launchOptions];
    NSDictionary *data = [self getInitData:launchOptions];
    
    // 获取冷启动原因：
    if (!launchOptions) {
        [self clearAppLaunchParams];
    } else if ([url isKindOfClass:[NSString class]] && url.length) {
        self.appLaunchParams = @{@"url": [TDCommonUtil string:url],
                                 @"data": @{}};
    } else {
        self.appLaunchParams = @{@"url": @"",
                                 @"data": [TDCommonUtil dictionary:data]};
    }
    
    id<UIApplicationDelegate> applicationDelegate = [[UIApplication sharedApplication] delegate];
    
    
    // hook 点击推送方法
    NSString *localPushSelString = @"application:didReceiveLocalNotification:";
    SEL newLocalPushSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", localPushSelString]);
    IMP newLocalPushIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, UILocalNotification *notification) {
        if ([_self respondsToSelector:newLocalPushSel]) {
            [NSObject performSelector:newLocalPushSel onTarget:_self withArguments:@[application, notification]];
        }
        
        BOOL isValidPushClick = NO;
        if (application.applicationState == UIApplicationStateInactive) {
            isValidPushClick = YES;
        }
        if (!isValidPushClick) {
//            TDLogDebug(@"Invalid app push callback, PushClick was ignored.");
            return;
        }
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        properties[@"alertBody"] = notification.alertBody;
        if (@available(iOS 8.2, *)) {
            properties[@"alertTitle"] = notification.alertTitle;
        }
        [self clearAppLaunchParams];
        weakSelf.appLaunchParams = @{@"url": @"",
                                     @"data": [TDCommonUtil dictionary:properties]};
    });
    __td_td_swizzleWithOriSELStr(applicationDelegate, localPushSelString, newLocalPushSel, newLocalPushIMP);
    
    
    NSString *remotePushSelString = @"application:didReceiveRemoteNotification:fetchCompletionHandler:";
    SEL newRemotePushSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", remotePushSelString]);
    IMP newRemotePushIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, NSDictionary *userInfo, id completionHandler) {
        if ([_self respondsToSelector:newRemotePushSel]) {
            [NSObject performSelector:newRemotePushSel onTarget:_self withArguments:@[application, userInfo, completionHandler]];
        }
        
        BOOL isValidPushClick = NO;
        if (application.applicationState == UIApplicationStateInactive) {
            isValidPushClick = YES;
        }
        if (!isValidPushClick) {
//            TDLogDebug(@"Invalid app push callback, PushClick was ignored.");
            return;
        }
        [self clearAppLaunchParams];
        weakSelf.appLaunchParams = @{@"url": @"",
                                     @"data": [TDCommonUtil dictionary:userInfo]};
    });
    __td_td_swizzleWithOriSELStr(applicationDelegate, remotePushSelString, newRemotePushSel, newRemotePushIMP);
    
    
    // hook deeplink回调方法
    NSString *deeplinkStr1 = @"application:handleOpenURL:";// ios(2.0, 9.0)
    SEL newdeeplinkSel1 = NSSelectorFromString([NSString stringWithFormat:@"td_%@", deeplinkStr1]);
    IMP newdeeplinkIMP1 = imp_implementationWithBlock(^(id _self, UIApplication *application, NSURL *url) {
        if ([_self respondsToSelector:newdeeplinkSel1]) {
            [NSObject performSelector:newdeeplinkSel1 onTarget:_self withArguments:@[application, url]];
        }
        
        [self clearAppLaunchParams];
        weakSelf.appLaunchParams = @{@"url": [TDCommonUtil string:url.absoluteString],
                                     @"data":@{}};
    });
    __td_td_swizzleWithOriSELStr(applicationDelegate, deeplinkStr1, newdeeplinkSel1, newdeeplinkIMP1);
    
    NSString *deeplinkStr2 = @"application:openURL:options:";// ios(9.0)
    SEL newdeeplinkSel2 = NSSelectorFromString([NSString stringWithFormat:@"td_%@", deeplinkStr2]);
    IMP newdeeplinkIMP2 = imp_implementationWithBlock(^(id _self, UIApplication *application, NSURL *url, NSDictionary *options) {
        if ([_self respondsToSelector:newdeeplinkSel2]) {
            [NSObject performSelector:newdeeplinkSel2 onTarget:_self withArguments:@[application, url, options]];
        }
        
        [self clearAppLaunchParams];
        weakSelf.appLaunchParams = @{@"url": [TDCommonUtil string:url.absoluteString],
                                     @"data":@{}};
    });
    __td_td_swizzleWithOriSELStr(applicationDelegate, deeplinkStr2, newdeeplinkSel2, newdeeplinkIMP2);
    
    NSString *deeplinkStr3 = @"application:continueUserActivity:restorationHandler:";// ios(8.0)
    SEL newdeeplinkSel3 = NSSelectorFromString([NSString stringWithFormat:@"td_%@", deeplinkStr3]);
    IMP newdeeplinkIMP3 = imp_implementationWithBlock(^(id _self, UIApplication *application, NSUserActivity *userActivity, id restorationHandler) {
        if ([_self respondsToSelector:newdeeplinkSel3]) {
            [NSObject performSelector:newdeeplinkSel3 onTarget:_self withArguments:@[application, userActivity, restorationHandler]];
        }
        
        [self clearAppLaunchParams];
        weakSelf.appLaunchParams = @{@"url": [TDCommonUtil string: userActivity.webpageURL.absoluteString],
                                     @"data":@{}};
    });
    __td_td_swizzleWithOriSELStr(applicationDelegate, deeplinkStr3, newdeeplinkSel3, newdeeplinkIMP3);
    
    
    // hook 3d touch回调方法
    if (@available(iOS 9.0, *)) {
        NSString *touch3dSel = @"application:performActionForShortcutItem:completionHandler:";
        SEL newtouch3dSel = NSSelectorFromString([NSString stringWithFormat:@"td_%@", touch3dSel]);
        IMP newtouch3dIMP = imp_implementationWithBlock(^(id _self, UIApplication *application, UIApplicationShortcutItem *shortcutItem, id completionHandler) {
            if ([_self respondsToSelector:newtouch3dSel]) {
                [NSObject performSelector:newtouch3dSel onTarget:_self withArguments:@[application, shortcutItem, completionHandler]];
            }
            
            [self clearAppLaunchParams];
            weakSelf.appLaunchParams = @{@"url": @"",
                                         @"data": [TDCommonUtil dictionary:shortcutItem.userInfo]};
        });
        __td_td_swizzleWithOriSELStr(applicationDelegate, touch3dSel, newtouch3dSel, newtouch3dIMP);
    }
}

- (NSString *)getInitDeeplink:(NSDictionary *)launchOptions {
    
    if (!launchOptions || ![launchOptions isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    
    if ([launchOptions isKindOfClass:[NSDictionary class]] &&
        [launchOptions.allKeys containsObject:UIApplicationLaunchOptionsURLKey]) {
        
        return launchOptions[UIApplicationLaunchOptionsURLKey];
        
    } else if ([launchOptions isKindOfClass:[NSDictionary class]] &&
               [launchOptions.allKeys containsObject:UIApplicationLaunchOptionsUserActivityDictionaryKey]) {
        
        NSDictionary *userActivityDictionary = launchOptions[UIApplicationLaunchOptionsUserActivityDictionaryKey];
        NSString *type = userActivityDictionary[UIApplicationLaunchOptionsUserActivityTypeKey];
        if ([type isEqualToString:NSUserActivityTypeBrowsingWeb]) {
            NSUserActivity *userActivity = userActivityDictionary[@"UIApplicationLaunchOptionsUserActivityKey"];
            return userActivity.webpageURL.absoluteString;
        }
    }
    return @"";
}

- (NSDictionary *)getInitData:(NSDictionary *)launchOptions {
    
    if (!launchOptions || ![launchOptions isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    
    if ([launchOptions.allKeys containsObject:UIApplicationLaunchOptionsLocalNotificationKey]) {
        // 本地推送可能会解析不出alertbody，这里特殊处理一下
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
        properties[@"alertBody"] = notification.alertBody;
        if (@available(iOS 8.2, *)) {
            properties[@"alertTitle"] = notification.alertTitle;
        }
        return properties;
    }
    
    return launchOptions;
}

@end
