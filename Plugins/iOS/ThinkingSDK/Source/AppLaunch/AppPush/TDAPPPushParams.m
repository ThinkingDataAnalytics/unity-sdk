//
//  TDAPPPushParams.m
//  ThinkingSDK
//
//  Created by Charles on 6.5.23.
//

#import "TDAPPPushParams.h"

id __td_get_userNotificationCenter(void) {
    Class cls = NSClassFromString(@"UNUserNotificationCenter");
    SEL sel = NSSelectorFromString(@"currentNotificationCenter");
    if ([cls respondsToSelector:sel]) {
        id (*getUserNotificationCenterIMP)(id, SEL) = (NSString * (*)(id, SEL))[cls methodForSelector:sel];
        return getUserNotificationCenterIMP(cls, sel);
    }
    return nil;
}

id __td_get_userNotificationCenter_delegate(void) {
    Class cls = NSClassFromString(@"UNUserNotificationCenter");
    SEL sel = NSSelectorFromString(@"currentNotificationCenter");
    SEL delegateSel = NSSelectorFromString(@"delegate");
    if ([cls respondsToSelector:sel]) {
        id (*getUserNotificationCenterIMP)(id, SEL) = (id (*)(id, SEL))[cls methodForSelector:sel];
        id center = getUserNotificationCenterIMP(cls, sel);
        if (center) {
            id (*getUserNotificationCenterDelegateIMP)(id, SEL) = (id (*)(id, SEL))[center methodForSelector:delegateSel];
            id delegate = getUserNotificationCenterDelegateIMP(center, delegateSel);
            return delegate;
        }
    }
    return nil;
}

NSDictionary * __td_get_userNotificationCenterResponse(id response) {
    
    @try {
        if ([response isKindOfClass:[NSClassFromString(@"UNNotificationResponse") class]]) {
            return [response valueForKeyPath:@"notification.request.content.userInfo"];
        }
    } @catch (NSException *exception) {
        
    }
    return nil;
}

NSString * __td_get_userNotificationCenterRequestContentTitle(id response) {
    
    @try {
        if ([response isKindOfClass:[NSClassFromString(@"UNNotificationResponse") class]]) {
            return [response valueForKeyPath:@"notification.request.content.title"];
        }
    } @catch (NSException *exception) {
        
    }
    return nil;
}

NSString * __td_get_userNotificationCenterRequestContentBody(id response) {
    
    @try {
        if ([response isKindOfClass:[NSClassFromString(@"UNNotificationResponse") class]]) {
            return [response valueForKeyPath:@"notification.request.content.body"];
        }
    } @catch (NSException *exception) {
        
    }
    return nil;
}
