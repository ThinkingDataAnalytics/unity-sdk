
#import "NSObject+TDDelegateProxy.h"
#import <objc/runtime.h>

static void *const kTDNSObjectDelegateOptionalSelectorsKey = (void *)&kTDNSObjectDelegateOptionalSelectorsKey;
static void *const kTDNSObjectDelegateObjectKey = (void *)&kTDNSObjectDelegateObjectKey;

static void *const kTDNSProxyDelegateOptionalSelectorsKey = (void *)&kTDNSProxyDelegateOptionalSelectorsKey;
static void *const kTDNSProxyDelegateObjectKey = (void *)&kTDNSProxyDelegateObjectKey;

@implementation NSObject (TDDelegateProxy)

- (NSSet<NSString *> *)thinkingdata_optionalSelectors {
    return objc_getAssociatedObject(self, kTDNSObjectDelegateOptionalSelectorsKey);
}

- (void)setThinkingdata_optionalSelectors:(NSSet<NSString *> *)thinkingdata_optionalSelectors {
    objc_setAssociatedObject(self, kTDNSObjectDelegateOptionalSelectorsKey, thinkingdata_optionalSelectors, OBJC_ASSOCIATION_COPY);
}

- (TDDelegateProxyObject *)thinkingdata_delegateObject {
    return objc_getAssociatedObject(self, kTDNSObjectDelegateObjectKey);
}

- (void)setThinkingdata_delegateObject:(TDDelegateProxyObject *)thinkingdata_delegateObject {
    objc_setAssociatedObject(self, kTDNSObjectDelegateObjectKey, thinkingdata_delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector {
    if ([self thinkingdata_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.thinkingdata_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

@end

@implementation NSProxy (TDDelegateProxy)

- (NSSet<NSString *> *)thinkingdata_optionalSelectors {
    return objc_getAssociatedObject(self, kTDNSProxyDelegateOptionalSelectorsKey);
}

- (void)setThinkingdata_optionalSelectors:(NSSet<NSString *> *)thinkingdata_optionalSelectors {
    objc_setAssociatedObject(self, kTDNSProxyDelegateOptionalSelectorsKey, thinkingdata_optionalSelectors, OBJC_ASSOCIATION_COPY);
}

- (TDDelegateProxyObject *)thinkingdata_delegateObject {
    return objc_getAssociatedObject(self, kTDNSProxyDelegateObjectKey);
}

- (void)setThinkingdata_delegateObject:(TDDelegateProxyObject *)thinkingdata_delegateObject {
    objc_setAssociatedObject(self, kTDNSProxyDelegateObjectKey, thinkingdata_delegateObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector {
    if ([self thinkingdata_respondsToSelector:aSelector]) {
        return YES;
    }
    if ([self.thinkingdata_optionalSelectors containsObject:NSStringFromSelector(aSelector)]) {
        return YES;
    }
    return NO;
}

@end
