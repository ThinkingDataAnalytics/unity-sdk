//
//  TDAutoPushPlugin.m
//  TDAutoPushPlugin.m
//  Pods
//
//  Created by 廖德生 on 2024/08/26.
//

#import "TDAutoPushPlugin.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#if __has_include(<ThinkingDataCore/ThinkingDataCore.h>)
#import <ThinkingDataCore/ThinkingDataCore.h>
#else
#import "ThinkingDataCore.h"
#endif

static BOOL _logOn = YES;
static NSString * _fcm_token = nil;
static NSString * _apns_token = nil;
static NSString * _jpush_token = nil;
static NSString * const TD_FCM_TOKEN = @"fcm_token";
static NSString * const TD_APNS_TOKEN = @"apns_token";
static NSString * const TD_JPUSH_TOKEN = @"jiguang_id";
static NSMutableSet<NSString *> * _pushAppIds;

typedef NS_ENUM(NSUInteger, TDAutoPushTokenKind) {
    TDAutoPushTokenKindFCM = 0,
    TDAutoPushTokenKindJPush,
    TDAutoPushTokenKindAPNS,
};

@interface TDAutoPushPlugin ()

+ (void)td_reportStoredToken:(NSString *)token kind:(TDAutoPushTokenKind)kind key:(NSString *)key;
+ (void)td_reportPendingTokenForKind:(TDAutoPushTokenKind)kind appId:(NSString *)appId key:(NSString *)key;

@end

@implementation TDAutoPushPlugin

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pushAppIds = [NSMutableSet set];
        [TDAutoPushPlugin monitorFIRMessagingToken];
        [TDAutoPushPlugin monitorJPUSHServiceToken];
        [TDAutoPushPlugin registerAnalyticsListener];
        [TDAutoPushPlugin registerAppLifeCycleListener];
    });
}

+ (NSString *)td_tokenForKind:(TDAutoPushTokenKind)kind {
    switch (kind) {
        case TDAutoPushTokenKindFCM:
            return _fcm_token;
        case TDAutoPushTokenKindJPush:
            return _jpush_token;
        case TDAutoPushTokenKindAPNS:
            return _apns_token;
    }
    return nil;
}

+ (void)td_setToken:(NSString *)token forKind:(TDAutoPushTokenKind)kind {
    switch (kind) {
        case TDAutoPushTokenKindFCM:
            _fcm_token = token;
            break;
        case TDAutoPushTokenKindJPush:
            _jpush_token = token;
            break;
        case TDAutoPushTokenKindAPNS:
            _apns_token = token;
            break;
    }
}

+ (NSArray<NSString *> *)td_storeToken:(NSString *)token kind:(TDAutoPushTokenKind)kind {
    @synchronized (TDAutoPushPlugin.class) {
        [self td_setToken:token forKind:kind];
        return [_pushAppIds allObjects];
    }
}

+ (NSString *)td_preparedTokenForKind:(TDAutoPushTokenKind)kind appId:(NSString *)appId {
    @synchronized (TDAutoPushPlugin.class) {
        NSString *token = [self td_tokenForKind:kind];
        if (token.length > 0) {
            return token;
        }
        if (appId.length > 0) {
            [_pushAppIds addObject:appId];
        }
        return nil;
    }
}

+ (void)td_reportStoredToken:(NSString *)token kind:(TDAutoPushTokenKind)kind key:(NSString *)key {
    NSArray<NSString *> *appIds = [self td_storeToken:token kind:kind];
    for (NSString *appId in appIds) {
        [self tdUserSetValue:token forKey:key appid:appId];
    }
}

+ (void)td_reportPendingTokenForKind:(TDAutoPushTokenKind)kind appId:(NSString *)appId key:(NSString *)key {
    NSString *token = [self td_preparedTokenForKind:kind appId:appId];
    if (token.length > 0) {
        [self tdUserSetValue:token forKey:key appid:appId];
    }
}

+ (void)enableLog:(BOOL)enable {
    _logOn = enable;
}

void (*td_fcm_imp_original)(id, SEL, id);
void td_fcm_imp_final(id self, SEL _cmd, id token) {
    [TDAutoPushPlugin printLog:@"FCM token: %@", token];
    [TDAutoPushPlugin td_reportStoredToken:token kind:TDAutoPushTokenKindFCM key:TD_FCM_TOKEN];
    if(td_fcm_imp_original) {
        td_fcm_imp_original(self, _cmd, token);
    }
}

+ (void)monitorFIRMessagingToken {
    Class desClass_FIRMessaging = objc_getClass("FIRMessaging");
    bool ret = NO;
    ret = class_addMethod(desClass_FIRMessaging, NSSelectorFromString(@"td_updateDefaultFCMToken:"), (IMP)(td_fcm_imp_final), "v@:@");
    if (ret) {
        Method method_original = class_getInstanceMethod(desClass_FIRMessaging, NSSelectorFromString(@"updateDefaultFCMToken:"));
        Method method_final = class_getInstanceMethod(desClass_FIRMessaging, NSSelectorFromString(@"td_updateDefaultFCMToken:"));
        td_fcm_imp_original = (void(*)(id, SEL, id))method_getImplementation(method_original);
        method_exchangeImplementations(method_original, method_final);
    }
}

+ (void)monitorJPUSHServiceToken {
    Class desClass = NSClassFromString(@"JPUSHService");
    void(^_handler)(int resCode, NSString *registrationID) = ^(int resCode, NSString *registrationID) {
        [TDAutoPushPlugin printLog:@"JPush registrationID: %@, resCode: %d", registrationID, resCode];
        [TDAutoPushPlugin td_reportStoredToken:registrationID kind:TDAutoPushTokenKindJPush key:TD_JPUSH_TOKEN];
    };
    SEL _sel = NSSelectorFromString(@"registrationIDCompletionHandler:");
    if ([desClass respondsToSelector:_sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [desClass performSelector:_sel withObject:_handler];
#pragma clang diagnostic pop
    }
}

+ (void)tdUserSetValue:(NSString *)value forKey:(NSString *)key appid:(NSString *)appId {
    if (value != nil && value.length > 0) {
        if ([[TDMediator sharedInstance] tdAnalyticsGetEnableAutoPushWithAppId: appId]) {
            [[TDMediator sharedInstance] tdAnalyticsUserSetProperties:@{key: value} appId:appId];
        }
    }
}

+ (void)registerAnalyticsListener {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTokenNotification:) name:kAnalyticsNotificationNameInit object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTokenNotification:) name:kAnalyticsNotificationNameLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushTokenNotification:) name:kAnalyticsNotificationNameSetDistinctId object:nil];
}

+ (void)pushTokenNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *appId = userInfo[kAnalyticsNotificationParamsAppId];
    [self td_reportPendingTokenForKind:TDAutoPushTokenKindFCM appId:appId key:TD_FCM_TOKEN];
    [self td_reportPendingTokenForKind:TDAutoPushTokenKindJPush appId:appId key:TD_JPUSH_TOKEN];
    [self td_reportPendingTokenForKind:TDAutoPushTokenKindAPNS appId:appId key:TD_APNS_TOKEN];
}

+ (void)registerAppLifeCycleListener {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(td_applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

static void (*original_didRegisterForRemoteNotificationsWithDeviceToken)(id, SEL, UIApplication *, NSData *);
+ (void)td_applicationDidFinishLaunching:(NSNotification *)notification {
    Class delegateClass = [UIApplication sharedApplication].delegate.class;
    
    SEL originalSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    SEL swizzledSelector = @selector(td_application:didRegisterForRemoteNotificationsWithDeviceToken:);
    
    Method originalMethod = class_getInstanceMethod(delegateClass, originalSelector);
    // 保存原有方法的实现
    original_didRegisterForRemoteNotificationsWithDeviceToken = (void (*)(id, SEL, UIApplication *, NSData *))method_getImplementation(originalMethod);
    
    Method swizzledMethod = class_getClassMethod([self class], swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)td_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenStr = [TDAutoPushPlugin formatDeviceTokenToHexStr:deviceToken];
    [TDAutoPushPlugin printLog:@"apns token: %@", tokenStr];
    [TDAutoPushPlugin td_reportStoredToken:tokenStr kind:TDAutoPushTokenKindAPNS key:TD_APNS_TOKEN];
    original_didRegisterForRemoteNotificationsWithDeviceToken(self, _cmd, application, deviceToken);
}

+ (NSString *)formatDeviceTokenToHexStr:(NSData *)deviceToken {
    NSString *tokenStr;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0) {
        const unsigned *tokenBytes = [deviceToken bytes];
        tokenStr = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                 ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                 ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                 ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    } else {
        tokenStr = [[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""];
        tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
        tokenStr = [tokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return tokenStr;
}

+ (void)printLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2) {
    if (_logOn == YES) {
        if (format) {
            va_list args;
            va_start(args, format);
            NSString *output = [[NSString alloc] initWithFormat:format arguments:args];
            va_end(args);
            
            NSString *prefix = @"TDAutoPushPlugin";
            [TDOSLog logMessage:output prefix:prefix type:TDLogTypeInfo asynchronous:YES];
        }
    }
}

@end
