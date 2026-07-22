//
//  UIViewController+TDScreenName.h
//  ThinkingSDK
//

#import <TargetConditionals.h>
#if TARGET_OS_IOS

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TDScreenName)

/// Returns a readable screen name for auto track. SwiftUI UIHostingController
/// classes are resolved to their root SwiftUI view type when possible.
+ (NSString *)td_screenNameForViewController:(UIViewController *)viewController;

+ (NSString *)td_screenNameForClass:(Class)viewControllerClass;

@end

NS_ASSUME_NONNULL_END

#endif // TARGET_OS_IOS
