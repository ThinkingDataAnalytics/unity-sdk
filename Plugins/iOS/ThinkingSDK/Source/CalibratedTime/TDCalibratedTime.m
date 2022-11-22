#import "TDCalibratedTime.h"

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
        self.serverTime = [[NSDate date] timeIntervalSince1970];
        self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
    }

    return self;
}

- (void)recalibrationWithTimeInterval:(NSTimeInterval)timestamp {
    self.serverTime = timestamp;
    self.systemUptime = [[NSProcessInfo processInfo] systemUptime];
}

@end
