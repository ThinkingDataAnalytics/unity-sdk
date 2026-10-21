
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
    // NSStringFromSelector / sel_getName on an untrusted SEL can SIGBUS
    // (iOS 18+ Swift special selectors, os_log flatten, app terminate).
    // Only AppDelegate / UNUserNotificationCenter.delegate have this set;
    // compare against known-good names instead of converting the incoming SEL.
    NSSet<NSString *> *optionalSelectors = self.thinkingdata_optionalSelectors;
    if (optionalSelectors.count == 0) {
        return NO;
    }
    for (NSString *selName in optionalSelectors) {
        if (![selName isKindOfClass:NSString.class] || selName.length == 0) {
            continue;
        }
        if (sel_isEqual(aSelector, NSSelectorFromString(selName))) {
            return YES;
        }
    }
    return NO;
}

@end
