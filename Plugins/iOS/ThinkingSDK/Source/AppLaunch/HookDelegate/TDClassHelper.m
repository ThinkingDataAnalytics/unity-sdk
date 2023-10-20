
#import "TDClassHelper.h"
#import <objc/runtime.h>

@implementation TDClassHelper

+ (Class _Nullable)allocateClassWithObject:(id)object className:(NSString *)className {
    if (!object || className.length <= 0) {
        return nil;
    }
    Class originalClass = object_getClass(object);
    Class subclass = NSClassFromString(className);
    if (subclass) {
        return nil;
    }
    subclass = objc_allocateClassPair(originalClass, className.UTF8String, 0);
    if (class_getInstanceSize(originalClass) != class_getInstanceSize(subclass)) {
        return nil;
    }
    return subclass;
}

+ (void)registerClass:(Class)cla {
    if (cla) {
        objc_registerClassPair(cla);
    }
}

+ (BOOL)setObject:(id)object toClass:(Class)cla {
    if (cla && object && object_getClass(object) != cla) {
        return object_setClass(object, cla);
    }
    return NO;
}

@end
