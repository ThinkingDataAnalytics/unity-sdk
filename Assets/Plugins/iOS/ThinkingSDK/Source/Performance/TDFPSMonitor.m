//
//  TDFPSMonitor.m
//  SSAPMSDK
//
//  Created by wwango on 2021/9/7.
//

#import "TDFPSMonitor.h"
#import <QuartzCore/CADisplayLink.h>
#import "TDWeakProxy.h"

@interface TDFPSMonitor () {
    CADisplayLink *_link;
    NSUInteger _count;
    NSTimeInterval _lastTime;
    int _thinkingdata_fps;
}

@end

@implementation TDFPSMonitor

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
    _link = [CADisplayLink displayLinkWithTarget:[TDWeakProxy proxyWithTarget:self] selector:@selector(tick:)];
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
    
//    NSLog(@"@@@@@FPS:%i", _thinkingdata_fps);
}


@end
