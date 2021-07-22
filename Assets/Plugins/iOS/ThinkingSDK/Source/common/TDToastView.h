#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 简单提示使用的的吐司
 */
@interface TDToastView : UIView

+ (instancetype)showInWindow:(UIWindow *)window text:(NSString *)text duration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
