
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDMethodHelper : NSObject

+ (IMP)implementationOfMethodSelector:(SEL)selector fromClass:(Class)aClass;

+ (void)addInstanceMethodWithSelector:(SEL)methodSelector fromClass:(Class)fromClass toClass:(Class)toClass;

+ (void)addInstanceMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass;

+ (void)addClassMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass;

+ (IMP _Nullable)replaceInstanceMethodWithDestinationSelector:(SEL)destinationSelector sourceSelector:(SEL)sourceSelector fromClass:(Class)fromClass toClass:(Class)toClass;

/// swizzle respondsToSelector 方法
/// 用于处理未实现代理方法也能采集事件的逻辑
+ (void)swizzleRespondsToSelector;

@end

NS_ASSUME_NONNULL_END
