
#import "TDMethodHelper.h"
#import <objc/runtime.h>
#import "TDNewSwizzle.h"

@implementation TDMethodHelper

+ (IMP)implementationOfMethodSelector:(SEL)selector fromClass:(Class)aClass {
    Method aMethod = class_getInstanceMethod(aClass, selector);
    return method_getImplementation(aMethod);
}

+ (void)addInstanceMethodWithSelector:(SEL)methodSelector fromClass:(Class)fromClass toClass:(Class)toClass {
    [self addInstanceMethodWithDestinationSelector:methodSelector sourceSelector:methodSelector fromClass:fromClass toClass:toClass];
}

+ (void)addInstanceMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass {
    Method method = class_getInstanceMethod(fromClass, sourceSelector);
    if (!method) {
        return;
    }
    IMP methodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    if (!class_addMethod(toClass, destinationSelector, methodIMP, types)) {
        IMP destinationIMP = [self implementationOfMethodSelector:destinationSelector fromClass:toClass];
        if (destinationIMP == methodIMP) {
            return;
        }
        class_replaceMethod(toClass, destinationSelector, methodIMP, types);
    }
}

+ (void)addClassMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass {
    Method method = class_getClassMethod(fromClass, sourceSelector);
    IMP methodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    if (!class_addMethod(toClass, destinationSelector, methodIMP, types)) {
        class_replaceMethod(toClass, destinationSelector, methodIMP, types);
    }
}

+ (IMP _Nullable)replaceInstanceMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass {
    Method method = class_getInstanceMethod(fromClass, sourceSelector);
    IMP methodIMP = method_getImplementation(method);
    const char *types = method_getTypeEncoding(method);
    return class_replaceMethod(toClass, destinationSelector, methodIMP, types);
}

+ (void)swizzleRespondsToSelector {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject td_new_swizzleMethod:@selector(respondsToSelector:)
                        withMethod:@selector(thinkingdata_respondsToSelector:)
                             error:NULL];
    });
}

@end
