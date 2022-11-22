#import "TDCalibratedTimeWithNTP.h"
#import "TDNTPServer.h"
#import "TDLogging.h"

@interface TDCalibratedTimeWithNTP()
@end

static dispatch_group_t _ta_ntpGroup;
static NSString *_ta_ntpQueuelabel;
static dispatch_queue_t _ta_ntpSerialQueue;

@implementation TDCalibratedTimeWithNTP

@synthesize serverTime = _serverTime;

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[TDCalibratedTimeWithNTP alloc] init];
        _ta_ntpGroup = dispatch_group_create();
        _ta_ntpQueuelabel = [NSString stringWithFormat:@"cn.thinkingdata.ntp.%p", (void *)self];
        _ta_ntpSerialQueue = dispatch_queue_create([_ta_ntpQueuelabel UTF8String], DISPATCH_QUEUE_SERIAL);
    });
    return sharedInstance;
}

- (void)recalibrationWithNtps:(NSArray *)ntpServers {
    
    if (_ta_ntpGroup) {
        TDLogDebug(@"ntp servers async start");
    } else {
        TDLogDebug(@"ntp servers async start, _ntpGroup is nil");
    }
    dispatch_group_async(_ta_ntpGroup, _ta_ntpSerialQueue, ^{
        [self startNtp:ntpServers];
    });
}

- (NSTimeInterval)serverTime {
    
    if (_ta_ntpGroup) {
        TDLogDebug(@"ntp _ntpGroup serverTime wait start");
        long ret = dispatch_group_wait(_ta_ntpGroup, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)));
        TDLogDebug(@"ntp _ntpGroup serverTime wait end");
        if (ret != 0) {
            self.stopCalibrate = YES;
            TDLogDebug(@"wait ntp time timeout");
        }
        return _serverTime;
    } else {
        self.stopCalibrate = YES;
        TDLogDebug(@"ntp _ntpGroup is nil !!!");
    }
    
    return 0;
    
}

- (void)startNtp:(NSArray *)ntpServerHost {
    NSMutableArray *serverHostArr = [NSMutableArray array];
    for (NSString *host in ntpServerHost) {
        if ([host isKindOfClass:[NSString class]] && host.length > 0) {
            [serverHostArr addObject:host];
        }
    }
    NSError *err;
    for (NSString *host in serverHostArr) {
        TDLogDebug(@"ntp host :%@", host);
        err = nil;
        TDNTPServer *server = [[TDNTPServer alloc] initWithHostname:host port:123];
        NSTimeInterval offset = [server dateWithError:&err];
        [server disconnect];
        
        if (err) {
            TDLogDebug(@"ntp failed :%@", err);
        } else {
            self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
            self.serverTime = [[NSDate dateWithTimeIntervalSinceNow:offset] timeIntervalSince1970];
            break;
        }
    }
    
    if (err) {
        TDLogDebug(@"get ntp time failed");
        self.stopCalibrate = YES;
    }
}

@end
