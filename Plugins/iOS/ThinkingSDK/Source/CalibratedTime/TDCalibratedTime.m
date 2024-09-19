#import "TDCalibratedTime.h"
#import "TDCommonUtil.h"
#import "TDNTPServer.h"
#import "TDLogging.h"

@implementation TDCalibratedTime

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.stopCalibrate = YES;
    }
    return self;
}

- (NSTimeInterval)serverTime {
    if (!_serverTime) {
        return [[NSDate date] timeIntervalSince1970];
    }
    return _serverTime;
}

- (void)recalibrationWithTimeInterval:(NSTimeInterval)timestamp {
    if (timestamp) {
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        TDLogInfo(@"Time Calibration with timestamp(%lf), diff = %lfms", timestamp * 1000, (timestamp - nowInterval) * 1000);
        self.stopCalibrate = NO;
        self.serverTime = timestamp;
        self.systemUptime = [TDCommonUtil uptime];
    }
}

- (void)recalibrationWithNtps:(NSArray *)ntpServers {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startNtp:ntpServers];
    });
}

- (void)startNtp:(NSArray *)ntpServerHost {
    NSError *err;
    for (NSString *host in ntpServerHost) {
        if (!([host isKindOfClass:[NSString class]] && host.length > 0)) {
            continue;
        }
        
        err = nil;
        TDNTPServer *server = [[TDNTPServer alloc] initWithHostname:host port:123];
        NSTimeInterval offset = [server dateWithError:&err];
        [server disconnect];
        
        if (err) {
            TDLogDebug(@"ntp failed. host: %@ error: %@", host, err);
        } else {
            TDLogInfo(@"Time Calibration with NTP(%@), diff = %lfms", host, (NSTimeInterval)(offset * 1000));
            self.systemUptime = [TDCommonUtil uptime];
            self.serverTime = [[NSDate dateWithTimeIntervalSinceNow:offset] timeIntervalSince1970];
            self.stopCalibrate = NO;
            break;
        }
    }
}

@end
