#import "TDCalibratedTime.h"
#import "TDCoreDeviceInfo.h"
#import "TDNTPServer.h"
#import "TDNotificationManager+Core.h"
#import "TDCoreLog.h"

@interface TDCalibratedTime ()
@property (atomic, assign) NSTimeInterval deviceBootTime;
@property (atomic, assign) NSTimeInterval serverTime;
@property (atomic, assign) BOOL hasBeenCalibrated;

@end


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
        self.hasBeenCalibrated = NO;
    }
    return self;
}

+ (NSDate *)now {
    NSDate *date = nil;
    TDCalibratedTime *calibrated = [TDCalibratedTime sharedInstance];
    if (calibrated.hasBeenCalibrated) {
        NSTimeInterval outTime = [TDCoreDeviceInfo bootTime] - calibrated.deviceBootTime;
        date = [NSDate dateWithTimeIntervalSince1970:(calibrated.serverTime + outTime)];
    } else {
        date = [NSDate date];
    }
    return date;
}

- (void)recalibrationWithTimeInterval:(NSTimeInterval)timestamp {
    if (timestamp > 0) {
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        TDCORELOG(@"SDK calibrateTime success. Timestamp(%lf), diff = %lfms", timestamp * 1000, (timestamp - nowInterval) * 1000);
        self.hasBeenCalibrated = YES;
        self.serverTime = timestamp;
        self.deviceBootTime = [TDCoreDeviceInfo bootTime];
        [TDNotificationManager postCoreNotificationCalibratedTimeSuccess:[TDCalibratedTime now]];
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
            TDCORELOG(@"ntp failed. host: %@ error: %@", host, err);
        } else {
            TDCORELOG(@"SDK calibrateTime success. NTP(%@), diff = %lfms", host, (NSTimeInterval)(offset * 1000));
            self.deviceBootTime = [TDCoreDeviceInfo bootTime];
            self.serverTime = [[NSDate dateWithTimeIntervalSinceNow:offset] timeIntervalSince1970];
            self.hasBeenCalibrated = YES;
            [TDNotificationManager postCoreNotificationCalibratedTimeSuccess:[TDCalibratedTime now]];
            break;
        }
    }
}

@end
