
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TDHookDelegateProtocol <NSObject>
@optional
+ (NSSet<NSString *> *)optionalSelectors;

@end

@interface TDDelegateProxy : NSObject <TDHookDelegateProtocol>

+ (void)proxyDelegate:(id)delegate selectors:(NSSet<NSString *>*)selectors;

+ (void)invokeWithTarget:(NSObject *)target selector:(SEL)selector, ...;

+ (BOOL)invokeReturnBOOLWithTarget:(NSObject *)target selector:(SEL)selector arg1:(id)arg1 arg2:(id)arg2;
+ (BOOL)invokeReturnBOOLWithTarget:(NSObject *)target selector:(SEL)selector arg1:(id)arg1 arg2:(id)arg2 arg3:(id)arg3;

+ (void)resolveOptionalSelectorsForDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
