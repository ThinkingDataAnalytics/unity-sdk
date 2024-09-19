#import "NSObject+TDSwizzle.h"

#if TARGET_OS_IPHONE
#import <objc/runtime.h>
#import <objc/message.h>
#else
#import <objc/objc-class.h>
#endif

@implementation NSObject (TDSwizzle)

+ (BOOL)td_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel error:(NSError **)error {
    Method origMethod = class_getInstanceMethod(self, origSel);
    if (!origMethod) {
        return NO;
    }
    
    Method altMethod = class_getInstanceMethod(self, altSel);
    if (!altMethod) {
        return NO;
    }
    
    class_addMethod(self,
                    origSel,
                    class_getMethodImplementation(self, origSel),
                    method_getTypeEncoding(origMethod));
    class_addMethod(self,
                    altSel,
                    class_getMethodImplementation(self, altSel),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(self, origSel), class_getInstanceMethod(self, altSel));
    
    return YES;
}

+ (BOOL)td_swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel error:(NSError **)error {
    return [object_getClass((id)self) td_swizzleMethod:origSel withMethod:altSel error:error];
}

@end
