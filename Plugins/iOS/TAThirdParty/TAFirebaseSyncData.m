//
//  TAFirebaseSyncData.m
//  ThinkingSDK.default-Base-Core-Extension-Util-iOS
//
//  Created by wwango on 2022/9/28.
//

#import "TAFirebaseSyncData.h"
#import <objc/runtime.h>
//#import <objc/message.h>

@implementation TAFirebaseSyncData

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    
    if (!self.customPropety || [self.customPropety isKindOfClass:[NSDictionary class]]) {
        self.customPropety = @{};
    }
    
//    NSString *distinctId = [taInstance getDistinctId] ? [taInstance getDistinctId] : @"";
//
//    Class cls = NSClassFromString(@"FIRAnalytics");
//    SEL sel = NSSelectorFromString(@"setUserID:");
//    if (cls && [cls respondsToSelector:sel]) {
//        [cls performSelector:sel withObject:distinctId];
//    }
    
    [self registTDMethods];
}


#pragma mark - Firebase Analytics

//// 原始方法实现
//void (*ori_method_logEventWithOrigin_IMP)(id, SEL, id, BOOL, id, id);
//// 交换方法实现
//void method_td_logEventWithOrigin_IMP(id self, SEL _cmd, id orgin, BOOL isPublicEvent, id name, id parameters) {
//    NSLog(@"This is a dynamic method: [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    if(ori_method_logEventWithOrigin_IMP) {
//        ori_method_logEventWithOrigin_IMP(self, _cmd, orgin, isPublicEvent, name, parameters);
//    }
//}

//// 原始方法实现
//void (*ori_method_queueOperationWithBlock_IMP)(id, SEL, id);
//// 交换方法实现
//void method_td_queueOperationWithBlock_IMP(id self, SEL _cmd, id block) {
//    NSLog(@"This is a dynamic method: [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
//    if(ori_method_queueOperationWithBlock_IMP) {
//        ori_method_queueOperationWithBlock_IMP(self, _cmd, block);
//    }
//}

// 原始方法实现
void (*ori_method_notifyEventListeners_IMP)(id, SEL, id);
// 交换方法实现
void method_td_notifyEventListeners_IMP(id self, SEL _cmd, id notify) {
    NSString *name = [notify valueForKey:@"_name"];
    //NSString *origin = [notify valueForKey:@"_origin"];
    NSDictionary *parameters = [notify valueForKey:@"_parameters"];
    [NSClassFromString(@"TDAnalytics") performSelector:NSSelectorFromString(@"track:properties:") withObject:name withObject:parameters];
    if(ori_method_notifyEventListeners_IMP) {
        ori_method_notifyEventListeners_IMP(self, _cmd, notify);
    }
}



// 原始方法实现
void (*ori_method_setUserPropertyString_IMP)(id, SEL, id, id);
// 交换方法实现
void method_td_setUserPropertyString_IMP(id self, SEL _cmd, id value, id name) {
    [NSClassFromString(@"TDAnalytics") performSelector:NSSelectorFromString(@"setSuperProperties:") withObject:[NSDictionary dictionaryWithObject:value forKey:name]];
    if(ori_method_setUserPropertyString_IMP) {
        ori_method_setUserPropertyString_IMP(self, _cmd, value, name);
    }
}

// 原始方法实现
void (*ori_method_setUserID_IMP)(id, SEL, id);
// 交换方法实现
void method_td_setUserID_IMP(id self, SEL _cmd, id userId) {
    [NSClassFromString(@"TDAnalytics") performSelector:NSSelectorFromString(@"setSuperProperties:") withObject:[NSDictionary dictionaryWithObject:userId forKey:@"userId"]];
    if(ori_method_setUserID_IMP) {
        ori_method_setUserID_IMP(self, _cmd, userId);
    }
}


// 原始方法实现
void (*ori_method_setDefaultEventParameters_IMP)(id, SEL, id);
// 交换方法实现
void method_td_setDefaultEventParameters_IMP(id self, SEL _cmd, id parameters) {
    [NSClassFromString(@"TDAnalytics") performSelector:NSSelectorFromString(@"setSuperProperties:") withObject:parameters];
    if(ori_method_setDefaultEventParameters_IMP) {
        ori_method_setDefaultEventParameters_IMP(self, _cmd, parameters);
    }
}

- (void)registTDMethods {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // APMAnalytics method exchange
        Class desClass_APMAnalytics = objc_getClass("APMAnalytics");
        Class metaClass_APMAnalytics = object_getClass(desClass_APMAnalytics);
        bool ret = NO;
        //ret = class_addMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_logEventWithOrigin:isPublicEvent:name:parameters:"), (IMP)(method_td_logEventWithOrigin_IMP), "v@:@B@@");
        //if (ret) {
        //    Method method_logEventWithOrigin = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"logEventWithOrigin:isPublicEvent:name:parameters:"));
        //    Method method_td_logEventWithOrigin = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_logEventWithOrigin:isPublicEvent:name:parameters:"));
        //    //保存原始实现
        //    ori_method_logEventWithOrigin_IMP = (void(*)(id, SEL, id, BOOL, id, id))method_getImplementation(method_logEventWithOrigin);
        //    //交换方法实现
        //    method_exchangeImplementations(method_logEventWithOrigin, method_td_logEventWithOrigin);
        //}
        
        //ret = class_addMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_queueOperationWithBlock:"), (IMP)(method_td_queueOperationWithBlock_IMP), "v@:@");
        //if (ret) {
        //    Method method_queueOperationWithBlock = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"queueOperationWithBlock:"));
        //    Method method_td_queueOperationWithBlock = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_queueOperationWithBlock:"));
        //    //保存原始实现
        //    ori_method_queueOperationWithBlock_IMP = (void(*)(id, SEL, id))method_getImplementation(method_queueOperationWithBlock);
        //    //交换方法实现
        //    method_exchangeImplementations(method_queueOperationWithBlock, method_td_queueOperationWithBlock);
        //}

        ret = class_addMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_notifyEventListeners:"), (IMP)(method_td_notifyEventListeners_IMP), "v@:@");
        if (ret) {
            Method method_notifyEventListeners = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"notifyEventListeners:"));
            Method method_td_notifyEventListeners = class_getClassMethod(metaClass_APMAnalytics, NSSelectorFromString(@"td_notifyEventListeners:"));
            //保存原始实现
            ori_method_notifyEventListeners_IMP = (void(*)(id, SEL, id))method_getImplementation(method_notifyEventListeners);
            //交换方法实现
            method_exchangeImplementations(method_notifyEventListeners, method_td_notifyEventListeners);
        }
        
        
        // FIRAnalytics method exchange
        Class desClass_FIRAnalytics = objc_getClass("FIRAnalytics");
        Class metaClass_FIRAnalytics = object_getClass(desClass_FIRAnalytics);
        ret = class_addMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setUserPropertyString:forName:"), (IMP)(method_td_setUserPropertyString_IMP), "v@:@@");
        if (ret) {
            Method method_setUserPropertyString = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"setUserPropertyString:forName:"));
            Method method_td_setUserPropertyString = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setUserPropertyString:forName:"));
            //保存原始实现
            ori_method_setUserPropertyString_IMP = (void(*)(id, SEL, id, id))method_getImplementation(method_setUserPropertyString);
            //交换方法实现
            method_exchangeImplementations(method_setUserPropertyString, method_td_setUserPropertyString);
        }

        
        ret = class_addMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setUserID:"), (IMP)(method_td_setUserID_IMP), "v@:@");
        if (ret) {
            Method method_setUserID = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"setUserID:"));
            Method method_td_setUserID = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setUserID:"));
            //保存原始实现
            ori_method_setUserID_IMP = (void(*)(id, SEL, id))method_getImplementation(method_setUserID);
            //交换方法实现
            method_exchangeImplementations(method_setUserID, method_td_setUserID);
        }
        
        
        ret = class_addMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setDefaultEventParameters:"), (IMP)(method_td_setDefaultEventParameters_IMP), "v@:@");
        if (ret) {
            Method method_setDefaultEventParameters = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"setDefaultEventParameters:"));
            Method method_td_setDefaultEventParameters = class_getClassMethod(metaClass_FIRAnalytics, NSSelectorFromString(@"td_setDefaultEventParameters:"));
            //保存原始实现
            ori_method_setDefaultEventParameters_IMP = (void(*)(id, SEL, id))method_getImplementation(method_setDefaultEventParameters);
            //交换方法实现
            method_exchangeImplementations(method_setDefaultEventParameters, method_td_setDefaultEventParameters);
        }
    });
}

#pragma clang diagnostic pop

@end
