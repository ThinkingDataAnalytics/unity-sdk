#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (TDSwizzle)

+ (BOOL)td_swizzleMethod:(SEL)origSel withMethod:(SEL)altSel error:(NSError **)error;
+ (BOOL)td_swizzleClassMethod:(SEL)origSel withClassMethod:(SEL)altSel error:(NSError **)error;

@end
NS_ASSUME_NONNULL_END
