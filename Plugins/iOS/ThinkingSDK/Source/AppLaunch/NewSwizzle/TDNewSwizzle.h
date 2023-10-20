
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDNewSwizzle)

+ (BOOL)td_new_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)td_new_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)td_new_swizzleMethod:(SEL)origSel_  withClass:(Class)altCla_ withMethod:(SEL)altSel_ error:(NSError **)error_;

@end

NS_ASSUME_NONNULL_END
