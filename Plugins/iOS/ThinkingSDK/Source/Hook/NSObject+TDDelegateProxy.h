
#import <Foundation/Foundation.h>
#import "TDDelegateProxyObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDDelegateProxy)

@property (nonatomic, copy, nullable) NSSet<NSString *> *thinkingdata_optionalSelectors;
@property (nonatomic, strong, nullable) TDDelegateProxyObject *thinkingdata_delegateObject;

/// hook respondsToSelector to resolve optional selectors
/// @param aSelector selector
- (BOOL)thinkingdata_respondsToSelector:(SEL)aSelector;

@end

NS_ASSUME_NONNULL_END
