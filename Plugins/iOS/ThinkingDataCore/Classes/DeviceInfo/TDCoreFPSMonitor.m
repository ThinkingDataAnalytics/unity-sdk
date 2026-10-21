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

// CADisplayLink 与主线程 RunLoop / CoreAnimation 强绑定，其创建、addToRunLoop:、
// invalidate 必须在主线程执行。采集链路可能在后台串行队列触发启停，故统一收敛到主线程。
static void td_fps_runOnMainThread(dispatch_block_t block) {
    if (!block) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

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
    // _thinkingdata_fps 为 int，原子读安全；仅返回快照，不触发任何 link 操作
    return @(_thinkingdata_fps);
}

- (void)dealloc {
    // 确保 link 在对象销毁前从主线程 RunLoop 摘除；仅捕获局部指针，不强引用 self，避免悬垂
    CADisplayLink *link = _link;
    _link = nil;
    if (link) {
        if ([NSThread isMainThread]) {
            [link invalidate];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [link invalidate];
            });
        }
    }
}

- (void)startDisplay {
    td_fps_runOnMainThread(^{
        if (self->_link) return;

        self->_thinkingdata_fps = 60;
        self->_link = [CADisplayLink displayLinkWithTarget:[TDCoreWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
    //    _link.preferredFrameRateRange = CAFrameRateRangeMake(60, 120, 120);
        [self->_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    });
}

- (void)stopDisplay {
    td_fps_runOnMainThread(^{
        if (self->_link) {
            [self->_link invalidate];
            self->_link = nil;
        }
    });
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
