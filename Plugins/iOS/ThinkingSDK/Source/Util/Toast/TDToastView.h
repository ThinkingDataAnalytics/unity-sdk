#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDToastView : UIView

+ (instancetype)showInWindow:(UIWindow *)window text:(NSString *)text duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
