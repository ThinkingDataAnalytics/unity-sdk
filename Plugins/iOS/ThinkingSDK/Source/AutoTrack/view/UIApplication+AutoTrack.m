#import "UIApplication+AutoTrack.h"
#import "TDAutoTrackManager.h"

@implementation UIApplication (AutoTrack)

- (BOOL)td_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event {
    if ([from isKindOfClass:[UIControl class]]) {
        if (([from isKindOfClass:[UISwitch class]] ||
            [from isKindOfClass:[UISegmentedControl class]] ||
            [from isKindOfClass:[UIStepper class]])) {
            [[TDAutoTrackManager sharedManager] trackEventView:from];
        }
        
        else if ([event isKindOfClass:[UIEvent class]] &&
                 event.type == UIEventTypeTouches &&
                 [[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
            [[TDAutoTrackManager sharedManager] trackEventView:from];
        }
    }
    
    return [self td_sendAction:action to:to from:from forEvent:event];
}

@end
