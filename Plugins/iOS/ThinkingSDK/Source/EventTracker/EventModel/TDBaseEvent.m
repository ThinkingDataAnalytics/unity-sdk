//
//  TDBaseEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDBaseEvent.h"

#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif

#import "TDLogging.h"
#import "ThinkingAnalyticsSDKPrivate.h"

NSString * const TD_BACKGROUND_DURATION = @"#background_duration";

kEDEventTypeName const TD_EVENT_TYPE_TRACK           = @"track";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_FIRST     = @"track_first";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE    = @"track_update";
kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE = @"track_overwrite";
kEDEventTypeName const TD_EVENT_TYPE_USER_DEL        = @"user_del";
kEDEventTypeName const TD_EVENT_TYPE_USER_ADD        = @"user_add";
kEDEventTypeName const TD_EVENT_TYPE_USER_SET        = @"user_set";
kEDEventTypeName const TD_EVENT_TYPE_USER_SETONCE    = @"user_setOnce";
kEDEventTypeName const TD_EVENT_TYPE_USER_UNSET      = @"user_unset";
kEDEventTypeName const TD_EVENT_TYPE_USER_APPEND     = @"user_append";
kEDEventTypeName const TD_EVENT_TYPE_USER_UNIQ_APPEND= @"user_uniq_append";

@interface TDBaseEvent ()
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation TDBaseEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        _time = [NSDate date];
        self.timeValueType = TDEventTimeValueTypeNone;
        self.uuid = [NSUUID UUID].UUIDString;
    }
    return self;
}

- (instancetype)initWithType:(TDEventType)type {
    if (self = [self init]) {
        self.eventType = type;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"#time"] = self.time;
    dict[@"#uuid"] = self.uuid;
    dict[@"#type"] = [self eventTypeString];
    if (self.accountId) {
        dict[@"#account_id"] = self.accountId;
    }
    if (self.distinctId) {
        dict[@"#distinct_id"] = self.distinctId;
    }
    dict[@"properties"] = self.properties;
    return dict;
}

- (NSMutableDictionary *)formatDateWithDict:(NSDictionary *)dict {
    if (dict == nil || ![dict isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    return [TDJSONUtil formatDateWithFormatter:self.h5ZoneOffSet ? self.h5TimeFormatter : self.timeFormatter dict:dict];
}

- (NSString *)eventTypeString {
    switch (self.eventType) {
        case TDEventTypeTrack: {
            return TD_EVENT_TYPE_TRACK;
        } break;
        case TDEventTypeTrackFirst: {
            
            return TD_EVENT_TYPE_TRACK;
        } break;
        case TDEventTypeTrackUpdate: {
            return TD_EVENT_TYPE_TRACK_UPDATE;
        } break;
        case TDEventTypeTrackOverwrite: {
            return TD_EVENT_TYPE_TRACK_OVERWRITE;
        } break;
        case TDEventTypeUserAdd: {
            return TD_EVENT_TYPE_USER_ADD;
        } break;
        case TDEventTypeUserSet: {
            return TD_EVENT_TYPE_USER_SET;
        } break;
        case TDEventTypeUserUnset: {
            return TD_EVENT_TYPE_USER_UNSET;
        } break;
        case TDEventTypeUserAppend: {
            return TD_EVENT_TYPE_USER_APPEND;
        } break;
        case TDEventTypeUserUniqueAppend: {
            return TD_EVENT_TYPE_USER_UNIQ_APPEND;
        } break;
        case TDEventTypeUserDel: {
            return TD_EVENT_TYPE_USER_DEL;
        } break;
        case TDEventTypeUserSetOnce: {
            return TD_EVENT_TYPE_USER_SETONCE;
        } break;
            
        default:
            return nil;
            break;
    }
}

+ (TDEventType)typeWithTypeString:(NSString *)typeString {
    if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK]) {
        return TDEventTypeTrack;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
        return TDEventTypeTrack;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
        return TDEventTypeTrackUpdate;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        return TDEventTypeTrackOverwrite;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_ADD]) {
        return TDEventTypeUserAdd;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_DEL]) {
        return TDEventTypeUserDel;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_SET]) {
        return TDEventTypeUserSet;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_UNSET]) {
        return TDEventTypeUserUnset;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_APPEND]) {
        return TDEventTypeUserAppend;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_UNIQ_APPEND]) {
        return TDEventTypeUserUniqueAppend;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_SETONCE]) {
        return TDEventTypeUserSetOnce;
    }
    return TDEventTypeNone;
}

//MARK: - Private

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    
}

//MARK: - Setter & Getter

- (NSMutableDictionary *)properties {
    if (!_properties) {
        _properties = [NSMutableDictionary dictionary];
    }
    return _properties;
}

-  (void)setTimeZone:(NSTimeZone *)timeZone {
    _timeZone = timeZone;
    
    self.timeFormatter.timeZone = timeZone ?: [NSTimeZone localTimeZone];
}

- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        _timeFormatter.dateFormat = kDefaultTimeFormat;
        _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        _timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        _timeFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    return _timeFormatter;
}

- (NSDateFormatter *)h5TimeFormatter {
    double timeZoneNumber = [self.h5ZoneOffSet doubleValue];
    NSString *prefix = timeZoneNumber >= 0 ? @"UTC+" : @"UTC-";
    int hours = (int)fabs(timeZoneNumber);
    int minutes = (int)((fabs(timeZoneNumber) - hours) * 60);
    NSString *minutesStr = minutes == 0 ? @":00" : [NSString stringWithFormat:@":%02d", minutes];
    NSString *result = [NSString stringWithFormat:@"%@%d%@", prefix, hours, minutesStr];
    self.timeFormatter.timeZone = [NSTimeZone timeZoneWithName: result];
    return self.timeFormatter;
}

- (void)setTime:(NSDate *)time {
    
    if (time) {
        [self willChangeValueForKey:@"time"];
        _time = time;
        [self didChangeValueForKey:@"time"];
    }
}

@end
