//
//  TDCoreFPSMonitor.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/24.
//

#import "TDCoreFPSMonitor.h"
#import <QuartzCore/CADisplayLink.h>
#import "TDCoreWeakProxy.h"
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

@interface TDCoreFPSMonitor ()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) int thinkingdata_fps;

@end

@implementation TDCoreFPSMonitor

#if TARGET_OS_IOS
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self stopDisplay];
    _count = 0;
    _lastTime = 0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startDisplay];
}
#endif

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if (_enable) {
        [self startDisplay];
    } else {
        [self stopDisplay];
    }
}

- (NSNumber *)getPFS {
    return [NSNumber numberWithInt:[NSString stringWithFormat:@"%d", _thinkingdata_fps].intValue];
}

- (void)dealloc {
    if (_link) {
        [_link invalidate];
    }
}

- (void)startDisplay {
    
    if (_link) return;
    
    _thinkingdata_fps = 60;
    _link = [CADisplayLink displayLinkWithTarget:[TDCoreWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
//    _link.preferredFrameRateRange = CAFrameRateRangeMake(60, 120, 120);
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopDisplay {
    if (_link) {
        [_link invalidate];
        _link= nil;
    }
}

- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1.0) return;
    _lastTime = link.timestamp;
    _thinkingdata_fps = _count / delta;
    _count = 0;
}

@end
