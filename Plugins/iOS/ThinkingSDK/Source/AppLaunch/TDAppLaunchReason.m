//
//  TDAppLaunchReason.m
//  ThinkingSDK
//
//  Created by wwango on 2021/11/17.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAppLaunchReason.h"
#import <objc/runtime.h>
#import "TDCommonUtil.h"
#import "TDAppState.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDAppDelegateProxyManager.h"
#import "TDPushClickEvent.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDAppLaunchReason

+ (void)load {
    [[NSNotificationCenter defaultCenter] addObserver:[TDAppLaunchReason sharedInstance] selector:@selector(_applicationDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[TDAppLaunchReason sharedInstance] selector:@selector(_applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

+ (void)td_ops_push_click:(NSDictionary *)userInfo {
    
    @try {
        if ([userInfo.allKeys containsObject:@"te_extras"] && [userInfo[@"te_extras"] isKindOfClass:[NSString class]]) {
            NSData *jsonData = [userInfo[@"te_extras"] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            NSDictionary *opsReceiptProperties = responseDic[@"#ops_receipt_properties"];
            if ([opsReceiptProperties isKindOfClass:[NSString class]]) {
                            NSString *opsStr = (NSString *)opsReceiptProperties;
                            opsReceiptProperties = [NSJSONSerialization JSONObjectWithData:[opsStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&err];
                        }
            if (opsReceiptProperties && [opsReceiptProperties isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *dic = [ThinkingAnalyticsSDK _getAllInstances];
                if(dic == nil || dic.count == 0){
                    appPushClickDic = opsReceiptProperties;
                }else{
                    for (NSString *instanceToken in dic.allKeys) {
                        ThinkingAnalyticsSDK *instance = dic[instanceToken];
                        TDPushClickEvent *pushEvent = [[TDPushClickEvent alloc]initWithName: @"te_ops_push_click"];
                        pushEvent.ops = opsReceiptProperties;
                        [instance autoTrackWithEvent:pushEvent properties:@{}];
                        [instance innerFlush];
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        
    }
}

+ (NSDictionary *)getAppPushDic{
    return appPushClickDic;
}

+ (void)clearAppPushParams{
    appPushClickDic = nil;
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
    
    // 发送推送事件
    if ([ThinkingAnalyticsSDK defaultInstance].config.enableAutoPush && launchOptions) {
        NSDictionary *remoteNotification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        [TDAppLaunchReason td_ops_push_click:remoteNotification];
    }
    
    // 记录冷启动启动原因
    if (![TDCorePresetDisableConfig disableStartReason]) {
        
        if (!launchOptions) {
            [weakSelf clearAppLaunchParams];
        } else if ([url isKindOfClass:[NSString class]] && url.length) {
            self.appLaunchParams = @{@"url": [TDCommonUtil string:url],
                                     @"data": @{}};
        } else {
            self.appLaunchParams = @{@"url": @"",
                                     @"data": [TDCommonUtil dictionary:data]};
        }
    }
    
    UIApplication *application = [TDAppState sharedApplication];
    id applicationDelegate = [application delegate];
    if (applicationDelegate == nil)
    {
        return;
    }
    
    if (![TDCorePresetDisableConfig disableStartReason]) {
        [[TDAppDelegateProxyManager defaultManager] proxyNotifications];
    }

    if (![TDCorePresetDisableConfig disableOpsReceiptProperties]) {
        [[TDAppDelegateProxyManager defaultManager] proxyNotifications];
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
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
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
#pragma clang diagnostic pop

    return launchOptions;
}

@end
