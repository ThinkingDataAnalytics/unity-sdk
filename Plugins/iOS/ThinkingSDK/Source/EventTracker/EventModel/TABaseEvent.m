//
//  TABaseEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TABaseEvent.h"

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

#import "ThinkingAnalyticsSDKPrivate.h"

kTAEventType const kTAEventTypeTrack = @"track";
kTAEventType const kTAEventTypeTrackFirst = @"track_first";
kTAEventType const kTAEventTypeTrackUpdate = @"track_update";
kTAEventType const kTAEventTypeTrackOverwrite = @"track_overwrite";
kTAEventType const kTAEventTypeUserSet = @"user_set";
kTAEventType const kTAEventTypeUserUnset = @"user_unset";
kTAEventType const kTAEventTypeUserAdd = @"user_add";
kTAEventType const kTAEventTypeUserDel = @"user_del";
kTAEventType const kTAEventTypeUserSetOnce = @"user_setOnce";
kTAEventType const kTAEventTypeUserAppend = @"user_append";
kTAEventType const kTAEventTypeUserUniqueAppend = @"user_uniq_append";

@interface TABaseEvent ()
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

@implementation TABaseEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _time = [NSDate date];
        self.timeValueType = TAEventTimeValueTypeNone;
        self.uuid = [NSUUID UUID].UUIDString;
    }
    return self;
}

- (instancetype)initWithType:(TAEventType)type {
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
    NSMutableDictionary *mutableDict = nil;
    if ([dict isKindOfClass:NSMutableDictionary.class]) {
        mutableDict = (NSMutableDictionary *)dict;
    } else {
        mutableDict = [dict mutableCopy];
    }
    
    NSArray<NSString *> *keys = dict.allKeys;
    for (NSInteger i = 0; i < keys.count; i++) {
        id value = dict[keys[i]];
        if ([value isKindOfClass:NSDate.class]) {
            NSString *newValue = [self.timeFormatter stringFromDate:(NSDate *)value];
            mutableDict[keys[i]] = newValue;
        } else if ([value isKindOfClass:NSDictionary.class]) {
            NSDictionary *newValue = [self formatDateWithDict:value];
            mutableDict[keys[i]] = newValue;
        }
    }
    return mutableDict;
}

- (NSString *)eventTypeString {
    switch (self.eventType) {
        case TAEventTypeTrack: {
            return TD_EVENT_TYPE_TRACK;
        } break;
        case TAEventTypeTrackFirst: {
            
            return TD_EVENT_TYPE_TRACK;
        } break;
        case TAEventTypeTrackUpdate: {
            return TD_EVENT_TYPE_TRACK_UPDATE;
        } break;
        case TAEventTypeTrackOverwrite: {
            return TD_EVENT_TYPE_TRACK_OVERWRITE;
        } break;
        case TAEventTypeUserAdd: {
            return TD_EVENT_TYPE_USER_ADD;
        } break;
        case TAEventTypeUserSet: {
            return TD_EVENT_TYPE_USER_SET;
        } break;
        case TAEventTypeUserUnset: {
            return TD_EVENT_TYPE_USER_UNSET;
        } break;
        case TAEventTypeUserAppend: {
            return TD_EVENT_TYPE_USER_APPEND;
        } break;
        case TAEventTypeUserUniqueAppend: {
            return TD_EVENT_TYPE_USER_UNIQ_APPEND;
        } break;
        case TAEventTypeUserDel: {
            return TD_EVENT_TYPE_USER_DEL;
        } break;
        case TAEventTypeUserSetOnce: {
            return TD_EVENT_TYPE_USER_SETONCE;
        } break;
            
        default:
            return nil;
            break;
    }
}

+ (TAEventType)typeWithTypeString:(NSString *)typeString {
    if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK]) {
        return TAEventTypeTrack;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
        return TAEventTypeTrack;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
        return TAEventTypeTrackUpdate;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        return TAEventTypeTrackOverwrite;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_ADD]) {
        return TAEventTypeUserAdd;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_DEL]) {
        return TAEventTypeUserDel;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_SET]) {
        return TAEventTypeUserSet;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_UNSET]) {
        return TAEventTypeUserUnset;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_APPEND]) {
        return TAEventTypeUserAppend;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_UNIQ_APPEND]) {
        return TAEventTypeUserUniqueAppend;
    } else if ([typeString isEqualToString:TD_EVENT_TYPE_USER_SETONCE]) {
        return TAEventTypeUserSetOnce;
    }
    return TAEventTypeNone;
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

- (void)setTime:(NSDate *)time {
    
    if (time) {
        [self willChangeValueForKey:@"time"];
        _time = time;
        [self didChangeValueForKey:@"time"];
    }
}

@end
