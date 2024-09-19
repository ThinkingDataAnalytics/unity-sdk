//
//  PushAutomaticTool.m
//  random_app
//
//  Created by huangdiao on 2023/10/23.
//

#import "TDAutoTrackPush.h"
#import <objc/runtime.h>
#if __has_include(<ThinkingSDK/ThinkingSDK.h>)
#import <ThinkingSDK/ThinkingSDK.h>
#else
#import "ThinkingSDK.h"
#endif
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDLogging.h"

//MARK: router
#if __has_include(<ThinkingDataCore/TAAnnotation.h>)
#import <ThinkingDataCore/TAAnnotation.h>
#else
#import "TAAnnotation.h"
#endif
#if __has_include(<ThinkingDataCore/TAModuleProtocol.h>)
#import <ThinkingDataCore/TAModuleProtocol.h>
#else
#import "TAModuleProtocol.h"
#endif
#if __has_include(<ThinkingDataCore/TAContext.h>)
#import <ThinkingDataCore/TAContext.h>
#else
#import "TAContext.h"
#endif

static NSString * _fcm_token = nil;
static NSString * _jpush_token = nil;

ThinkingMod(TDAutoTrackPush)
@interface TDAutoTrackPush () <TAModuleProtocol>

@end

@implementation TDAutoTrackPush

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self monitorFIRMessagingToken];
        [self monitorJPUSHServiceToken];
    });
}

void (*IMP_original)(id, SEL, id);
void IMP_final(id self, SEL _cmd, id token) {
    TDLogInfo(@"FCM token: %@", token);
    [TDAutoTrackPush tdUserSetValue:token forKey:TD_FCM_TOKEN];
    _fcm_token = token;
    if(IMP_original) {
        IMP_original(self, _cmd, token);
    }
}

+ (void)monitorFIRMessagingToken {
    Class desClass_FIRMessaging = objc_getClass("FIRMessaging");
    bool ret = NO;
    ret = class_addMethod(desClass_FIRMessaging, NSSelectorFromString(@"td_updateDefaultFCMToken:"), (IMP)(IMP_final), "v@:@");
    if (ret) {
        Method method_original = class_getInstanceMethod(desClass_FIRMessaging, NSSelectorFromString(@"updateDefaultFCMToken:"));
        Method method_final = class_getInstanceMethod(desClass_FIRMessaging, NSSelectorFromString(@"td_updateDefaultFCMToken:"));
        IMP_original = (void(*)(id, SEL, id))method_getImplementation(method_original);
        method_exchangeImplementations(method_original, method_final);
    }
}


+ (void)monitorJPUSHServiceToken {
    Class desClass = NSClassFromString(@"JPUSHService");
    void(^_handler)(int resCode, NSString *registrationID) = ^(int resCode, NSString *registrationID) {
        TDLogInfo(@"JPush registrationID: %@, resCode: %d", registrationID, resCode);
        _jpush_token = registrationID;
        [TDAutoTrackPush tdUserSetValue:registrationID forKey:TD_JPUSH_TOKEN];
    };
    SEL _sel = NSSelectorFromString(@"registrationIDCompletionHandler:");
    if ([desClass respondsToSelector:_sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [desClass performSelector:_sel withObject:_handler];
#pragma clang diagnostic pop
    }
}

static NSString *const TD_FCM_TOKEN = @"fcm_token";
static NSString *const TD_JPUSH_TOKEN = @"jiguang_id";
+ (void)tdUserSetValue:(NSString *)value forKey:(NSString *)key {
    if (value != nil && value.length > 0) {
        if ([ThinkingAnalyticsSDK defaultInstance].config.enableAutoPush == YES) {
            [TDAnalytics userSet:@{ key: value }];
        }
    }
}

- (void)modDidCustomEvent:(TAContext *)context {
    NSString *moduleName = context.customParam[@"module"];
    NSDictionary *params = context.customParam[@"params"];
    
    if ([moduleName isEqualToString:@"ThinkingDataAnalytics"]) {
        NSString *eventType = params[@"type"];
        if ([eventType isEqualToString:@"TDAnalyticsInit"] || [eventType isEqualToString:@"TDAnalyticsLogin"] || [eventType isEqualToString:@"TDAnalyticsSetDistinctId"]) {
            if (_fcm_token != nil) {
                [TDAutoTrackPush tdUserSetValue:_fcm_token forKey:TD_FCM_TOKEN];
            }
            if (_jpush_token != nil) {
                [TDAutoTrackPush tdUserSetValue:_jpush_token forKey:TD_JPUSH_TOKEN];
            }
        }
    }
}

@end
