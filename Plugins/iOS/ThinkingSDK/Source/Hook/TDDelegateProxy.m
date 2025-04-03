
#import "TDDelegateProxy.h"
#import "TDLogging.h"

#if __has_include(<ThinkingDataCore/TDClassHelper.h>)
#import <ThinkingDataCore/TDClassHelper.h>
#else
#import "TDClassHelper.h"
#endif
#if __has_include(<ThinkingDataCore/TDMethodHelper.h>)
#import <ThinkingDataCore/TDMethodHelper.h>
#else
#import "TDMethodHelper.h"
#endif
#import "NSObject+TDDelegateProxy.h"
#import <objc/message.h>

static NSString * const kTDNSObjectRemoveObserverSelector = @"removeObserver:forKeyPath:";
static NSString * const kTDNSObjectAddObserverSelector = @"addObserver:forKeyPath:options:context:";
static NSString * const kTDNSObjectClassSelector = @"class";

@implementation TDDelegateProxy

+ (void)proxyDelegate:(id)delegate selectors:(NSSet<NSString *> *)selectors {
    if (object_isClass(delegate) || selectors.count == 0) {
        return;
    }
    
    Class proxyClass = [self class];
    NSMutableSet *delegateSelectors = [NSMutableSet setWithSet:selectors];
    
    TDDelegateProxyObject *object = [delegate thinkingdata_delegateObject];
    if (!object) {
        object = [[TDDelegateProxyObject alloc] initWithDelegate:delegate proxy:proxyClass];
        [delegate setThinkingdata_delegateObject:object];
    }
    
    [delegateSelectors minusSet:object.selectors];
    if (delegateSelectors.count == 0) {
        return;
    }
    
    if (object.thinkingClass) {
        [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:object.thinkingClass];
        [object.selectors unionSet:delegateSelectors];
        
        if (![object_getClass(delegate) isSubclassOfClass:object.thinkingClass]) {
            [TDClassHelper setObject:delegate toClass:object.thinkingClass];
        }
        return;
    }
    
    if (object.kvoClass) {
        if ([delegate isKindOfClass:NSObject.class] && ![object.selectors containsObject:kTDNSObjectRemoveObserverSelector]) {
            [delegateSelectors addObject:kTDNSObjectRemoveObserverSelector];
        }
        [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:object.kvoClass];
        [object.selectors unionSet:delegateSelectors];
        return;
    }
    
    Class thinkingClass = [TDClassHelper allocateClassWithObject:delegate className:object.thinkingClassName];
    [TDClassHelper registerClass:thinkingClass];
    
    if ([delegate isKindOfClass:NSObject.class] && ![object.selectors containsObject:kTDNSObjectAddObserverSelector]) {
        [delegateSelectors addObject:kTDNSObjectAddObserverSelector];
    }
    
    if (![object.selectors containsObject:kTDNSObjectClassSelector]) {
        [delegateSelectors addObject:kTDNSObjectClassSelector];
    }
    
    [self addInstanceMethodWithSelectors:delegateSelectors fromClass:proxyClass toClass:thinkingClass];
    [object.selectors unionSet:delegateSelectors];
    
    [TDClassHelper setObject:delegate toClass:thinkingClass];
}

+ (void)addInstanceMethodWithSelectors:(NSSet<NSString *> *)selectors fromClass:(Class)fromClass toClass:(Class)toClass {
    for (NSString *selector in selectors) {
        SEL sel = NSSelectorFromString(selector);
        [TDMethodHelper addInstanceMethodWithSelector:sel fromClass:fromClass toClass:toClass];
    }
}

+ (BOOL)invokeReturnBOOLWithTarget:(NSObject *)target selector:(SEL)selector arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3 {
    Class originalClass = target.thinkingdata_delegateObject.delegateISA;

    struct objc_super targetSuper = {
        .receiver = target,
        .super_class = originalClass
    };

    BOOL returnValue = NO;
    @try {
        returnValue = ((BOOL (*)(struct objc_super *, SEL, id, id, id))objc_msgSendSuper)(&targetSuper, selector, arg1, arg2, arg3);
    } @catch (NSException *exception) {
        TDLogInfo(@"msgSendSuper with exception: %@", exception);
    } @finally {
      
    }
    return returnValue;
}

+ (BOOL)invokeReturnBOOLWithTarget:(NSObject *)target selector:(SEL)selector arg1:(id)arg1 arg2:(id)arg2 {
    Class originalClass = target.thinkingdata_delegateObject.delegateISA;

    struct objc_super targetSuper = {
        .receiver = target,
        .super_class = originalClass
    };

    BOOL returnValue = NO;
    @try {
        returnValue = ((BOOL (*)(struct objc_super *, SEL, id, id))objc_msgSendSuper)(&targetSuper, selector, arg1, arg2);
    } @catch (NSException *exception) {
        TDLogInfo(@"msgSendSuper with exception: %@", exception);
    } @finally {
      
    }
    return returnValue;
}

+ (void)invokeWithTarget:(NSObject *)target selector:(SEL)selector, ... {
    Class originalClass = target.thinkingdata_delegateObject.delegateISA;

    va_list args;
    va_start(args, selector);
    id arg1 = nil, arg2 = nil, arg3 = nil, arg4 = nil;
    NSInteger count = [NSStringFromSelector(selector) componentsSeparatedByString:@":"].count - 1;
    for (NSInteger i = 0; i < count; i++) {
        i == 0 ? (arg1 = va_arg(args, id)) : nil;
        i == 1 ? (arg2 = va_arg(args, id)) : nil;
        i == 2 ? (arg3 = va_arg(args, id)) : nil;
        i == 3 ? (arg4 = va_arg(args, id)) : nil;
    }
    struct objc_super targetSuper = {
        .receiver = target,
        .super_class = originalClass
    };

    @try {
        void (*func)(struct objc_super *, SEL, id, id, id, id) = (void *)&objc_msgSendSuper;
        func(&targetSuper, selector, arg1, arg2, arg3, arg4);
    } @catch (NSException *exception) {
        TDLogInfo(@"msgSendSuper with exception: %@", exception);
    } @finally {
        va_end(args);
    }
}


+ (void)resolveOptionalSelectorsForDelegate:(id)delegate {
    if (object_isClass(delegate)) {
        return;
    }

    NSSet *currentOptionalSelectors = ((NSObject *)delegate).thinkingdata_optionalSelectors;
    NSMutableSet *optionalSelectors = [[NSMutableSet alloc] init];
    if (currentOptionalSelectors) {
        [optionalSelectors unionSet:currentOptionalSelectors];
    }
    
    if ([self respondsToSelector:@selector(optionalSelectors)] &&[self optionalSelectors]) {
        [optionalSelectors unionSet:[self optionalSelectors]];
    }
    ((NSObject *)delegate).thinkingdata_optionalSelectors = [optionalSelectors copy];
}

@end

#pragma mark - Class
@implementation TDDelegateProxy (Class)

- (Class)class {
    if (self.thinkingdata_delegateObject.delegateClass) {
        return self.thinkingdata_delegateObject.delegateClass;
    }
    return [super class];
}

@end

#pragma mark - KVO
@implementation TDDelegateProxy (KVO)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
    if (self.thinkingdata_delegateObject) {
        [TDMethodHelper replaceInstanceMethodWithDestinationSelector:@selector(class) sourceSelector:@selector(class) fromClass:TDDelegateProxy.class toClass:object_getClass(self)];
    }
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    BOOL oldClassIsKVO = [TDDelegateProxyObject isKVOClass:object_getClass(self)];
    [super removeObserver:observer forKeyPath:keyPath];
    BOOL newClassIsKVO = [TDDelegateProxyObject isKVOClass:object_getClass(self)];
    
    if (oldClassIsKVO && !newClassIsKVO) {
        Class delegateProxy = self.thinkingdata_delegateObject.delegateProxy;
        NSSet *selectors = [self.thinkingdata_delegateObject.selectors copy];

        [self.thinkingdata_delegateObject removeKVO];
        if ([delegateProxy respondsToSelector:@selector(proxyDelegate:selectors:)]) {
            [delegateProxy proxyDelegate:self selectors:selectors];
        }
    }
}

@end
