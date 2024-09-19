
#import "TDEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDEventModel ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) kEDEventTypeName eventType;

@end

@implementation TDEventModel

- (instancetype)initWithEventName:(NSString *)eventName eventType:(kEDEventTypeName)eventType {
    if (self = [[[TDEventModel class] alloc] init]) {
        self.eventName = eventName ?: @"";
        self.eventType = eventType ?: @"";
        if ([self.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            _extraID = [TDDeviceInfo sharedManager].deviceId ?: @"";
        }
    }
    return self;
}

#pragma mark - Public

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone *)timeZone {
    self.time = time;
    self.timeZone = timeZone;
}

#pragma mark - Setter

- (void)setExtraID:(NSString *)extraID {
    if (extraID.length > 0) {
        _extraID = extraID;
    } else {
        if ([self.eventType isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            TDLogError(@"Invalid firstCheckId. Use device Id");
        } else {
            TDLogError(@"Invalid eventId");
        }
    }
}

@end
