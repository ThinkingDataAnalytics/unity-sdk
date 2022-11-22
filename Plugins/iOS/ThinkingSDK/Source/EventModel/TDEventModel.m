
#import "TDEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

kEDEventTypeName const TD_EVENT_TYPE_TRACK_FIRST       = @"track_first";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE       = @"track_update";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE    = @"track_overwrite";

@interface TDEventModel ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) kEDEventTypeName eventType;

@end

@implementation TDEventModel

- (instancetype)initWithEventName:(NSString *)eventName {
    return [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK];
}

- (instancetype)initWithEventName:(NSString *)eventName eventType:(kEDEventTypeName)eventType {
    if (self = [[[TDEventModel class] alloc] init]) {
        self.persist = YES;
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
    if (!time || ![time isKindOfClass:[NSDate class]]) {
        self.timeValueType = TDTimeValueTypeNone;
    } else {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = kDefaultTimeFormat;
        timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        if (timeZone && [timeZone isKindOfClass:[NSTimeZone class]]) {
            self.timeValueType = TDTimeValueTypeAll;
            timeFormatter.timeZone = timeZone;
        } else {
            self.timeValueType = TDTimeValueTypeTimeOnly;
            timeFormatter.timeZone = [NSTimeZone localTimeZone];
        }
        self.timeString = [timeFormatter stringFromDate:time];
    }
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
