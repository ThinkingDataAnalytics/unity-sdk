
#import "NSObject+TDDelegateProxy.h"
#import <objc/runtime.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

@implementation NSObject (TDDelegateProxy)

- (NSSet<NSString *> *)thinkingdata_optionalSelectors {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_optionalSelectors:(NSSet<NSString *> *)thinkingdata_optionalSelectors {
    objc_setAssociatedObject(self, @selector(thinkingdata_optionalSelectors), thinkingdata_optionalSelectors, OBJC_ASSOCIATION_COPY);
}

- (TDDelegateProxyObject *)thinkingdata_delegateObject {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setThinkingdata_delegateObject:(TDDelegateProxyObject *)thinkingdata_delegateObject {
    objc_setAssociatedObject(self, @selector(thinkingdata_delegateObject), thinkingdata_delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector {
    if ([self thinkingdata_respondsToSelector:aSelector]) {
        return YES;
    }
    if (@available(iOS 18.0, *)) {
        char startOfHeader = (char)sel_getName(aSelector);
        if (startOfHeader == '\x01') {
            return NO;
        }
    }
    if ([self.thinkingdata_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

@end
