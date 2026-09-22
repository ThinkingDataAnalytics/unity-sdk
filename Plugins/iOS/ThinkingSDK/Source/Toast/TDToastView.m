#import "TDToastView.h"

@implementation TDToastView
{
    UITextView *_textView;
}

#define TOAST_HORIZONTAL_PADDING 20.0
#define TOAST_VERTICAL_PADDING 15.0

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.opaque = NO;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.userInteractionEnabled = YES;
        [self addSubview:_textView];
        self.alpha = 0.9;
        self.backgroundColor = [UIColor darkGrayColor];
        self.layer.cornerRadius = 20.0;
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapHandler:)]];
    }
    return self;
}

+ (instancetype)showInWindow:(UIWindow *)window text:(NSString *)text duration:(NSTimeInterval)duration {
    TDToastView *toast = [[self alloc] initWithFrame:CGRectZero];
    toast.text = text;
    [toast showInWindow:window duration:duration];
    return toast;
}


- (void)showInWindow:(UIWindow *)window duration:(NSTimeInterval)duration {
    if (window == nil) {
        return;
    }
    CGRect windowBounds = CGRectInset(window.bounds, 20.0, 20.0);
    CGRect toastBounds = CGRectZero;
    toastBounds.size = [self sizeThatFits:windowBounds.size];
    self.bounds = toastBounds;
    self.center = CGPointMake(CGRectGetMidX(windowBounds), CGRectGetMidY(windowBounds));
    CGFloat alpha = self.alpha;
    self.alpha = 0.0;
    [window addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = alpha;
    } completion:^(BOOL finishedShowing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismiss];
        });
    }];
}

- (NSString *)text {
    return _textView.text;
}

- (void)setText:(NSString *)text {
    _textView.text = text;
}

- (void)dismiss {
    if (!self.superview) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finishedHiding) {
        [self removeFromSuperview];
    }];
}

- (void)_tapHandler:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismiss];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textView.frame = CGRectInset(self.bounds, TOAST_HORIZONTAL_PADDING, TOAST_VERTICAL_PADDING);
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize textConstrainedSize = CGSizeMake(size.width - 2 * TOAST_HORIZONTAL_PADDING,
                                          size.height - 2 * TOAST_VERTICAL_PADDING);
    CGSize textSize = [_textView sizeThatFits:textConstrainedSize];
    CGFloat width = MIN(size.width, textSize.width + 2 * TOAST_HORIZONTAL_PADDING);
    CGFloat height = MIN(size.height, textSize.height + 2 * TOAST_VERTICAL_PADDING);
    return CGSizeMake(width, height);
}

@end
