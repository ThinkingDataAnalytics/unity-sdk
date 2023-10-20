
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDAppDelegateProxyManager : NSObject

+ (instancetype)defaultManager;

- (void)proxyNotifications;

@end

NS_ASSUME_NONNULL_END
