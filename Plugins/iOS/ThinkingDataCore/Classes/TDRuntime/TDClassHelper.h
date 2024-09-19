
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDClassHelper : NSObject

+ (Class _Nullable)allocateClassWithObject:(id)object className:(NSString *)className;

+ (void)registerClass:(Class)cla;

+ (BOOL)setObject:(id)object toClass:(Class)cla;

@end

NS_ASSUME_NONNULL_END
