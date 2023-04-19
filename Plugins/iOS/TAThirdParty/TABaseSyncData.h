//
//  TABaseSyncData.h
//  ThinkingSDK
//
//  Created by wwango on 2022/2/14.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "TAThirdPartySyncProtocol.h"

#define TA_DISTINCT_ID @"ta_distinct_id"
#define TA_ACCOUNT_ID  @"ta_account_id"


#define td_force_inline __inline__ __attribute__((always_inline))


#define TASyncDataKey @"TASyncDataKey"


NS_ASSUME_NONNULL_BEGIN

static td_force_inline void __td_td__swizzleWithClassMethod(Class c, NSString *oriSELStr, SEL newSel, IMP newIMP) {
    SEL orig = NSSelectorFromString(oriSELStr);
    Method origMethod = class_getClassMethod(c, orig);
    c = object_getClass((id)c);
    
    class_addMethod(c, newSel, newIMP, method_getTypeEncoding(origMethod));
    
    
    if(class_addMethod(c, orig, newIMP, method_getTypeEncoding(origMethod))) {
        class_replaceMethod(c, newSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        Method newMethod = class_getClassMethod(c, newSel);
        method_exchangeImplementations(origMethod, newMethod);
    }
}


static td_force_inline void __td_td_swizzleWithOriSELStr(id target, NSString *oriSELStr, SEL newSEL, IMP newIMP) {
    SEL origSEL = NSSelectorFromString(oriSELStr);
    Method origMethod = class_getInstanceMethod([target class], origSEL);
    
    if ([target respondsToSelector:origSEL]) {

        class_addMethod([target class], newSEL, newIMP, method_getTypeEncoding(origMethod));
        

        Method origMethod = class_getInstanceMethod([target class], origSEL);

        Method newMethod = class_getInstanceMethod([target class], newSEL);
        

        if(class_addMethod([target class], origSEL, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
            
            class_replaceMethod([target class], newSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        } else {

            method_exchangeImplementations(origMethod, newMethod);
        }
    } else {

        class_addMethod([target class], origSEL, newIMP, method_getTypeEncoding(origMethod));
    }
}

@interface TABaseSyncData : NSObject<TAThirdPartySyncProtocol>
 
@property (nonatomic, weak) id<TAThinkingTrackProtocol> taInstance;
@property (nonatomic, strong) NSDictionary *customPropety;
@property (nonatomic, assign) BOOL isSwizzleMethod;

@end

NS_ASSUME_NONNULL_END
