
#import "TDDelegateProxyObject.h"
#import <objc/message.h>

NSString * const kTDDelegateClassThinkingSuffix = @"_TD.THINKINGDATA";
NSString * const kTDDelegateClassKVOPrefix = @"KVONotifying_";

@implementation TDDelegateProxyObject

- (instancetype)initWithDelegate:(id)delegate proxy:(id)proxy {
    self = [super init];
    if (self) {
        _delegateProxy = proxy;

        _selectors = [NSMutableSet set];
        _delegateClass = [delegate class];

        Class cla = object_getClass(delegate);
        NSString *name = NSStringFromClass(cla);

        if ([name containsString:kTDDelegateClassKVOPrefix]) {
            _delegateISA = class_getSuperclass(cla);
            _kvoClass = cla;
        } else if ([name containsString:kTDDelegateClassThinkingSuffix]) {
            _delegateISA = class_getSuperclass(cla);
            _thinkingClassName = name;
        } else {
            _delegateISA = cla;
            _thinkingClassName = [NSString stringWithFormat:@"%@%@", name, kTDDelegateClassThinkingSuffix];
        }
    }
    return self;
}

- (Class)thinkingClass {
    return NSClassFromString(self.thinkingClassName);
}

- (void)removeKVO {
    self.kvoClass = nil;
    self.thinkingClassName = [NSString stringWithFormat:@"%@%@", self.delegateISA, kTDDelegateClassThinkingSuffix];
    [self.selectors removeAllObjects];
}

@end

#pragma mark - Utils

@implementation TDDelegateProxyObject (Utils)

+ (BOOL)isKVOClass:(Class _Nullable)cls {
    return [NSStringFromClass(cls) containsString:kTDDelegateClassKVOPrefix];
}

@end

