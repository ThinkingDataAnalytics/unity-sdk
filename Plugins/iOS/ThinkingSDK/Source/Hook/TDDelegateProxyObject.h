
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDDelegateProxyObject : NSObject

@property (nonatomic, strong) Class delegateISA;

@property (nonatomic, strong, nullable) Class kvoClass;

@property (nonatomic, copy, nullable) NSString *thinkingClassName;

@property (nonatomic, strong, readonly, nullable) Class thinkingClass;

@property (nonatomic, strong) id delegateClass;

@property (nonatomic, strong) Class delegateProxy;

@property (nonatomic, strong) NSMutableSet *selectors;

- (instancetype)initWithDelegate:(id)delegate proxy:(id)proxy;

- (void)removeKVO;

@end

@interface TDDelegateProxyObject (Utils)

+ (BOOL)isKVOClass:(Class _Nullable)cls;

@end

NS_ASSUME_NONNULL_END
