//
//  TDBaseEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import <Foundation/Foundation.h>
#import "TDPropertyValidator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString * kTDEventType;

typedef NS_OPTIONS(NSUInteger, TDEventType) {
    TDEventTypeNone = 0,
    TDEventTypeTrack = 1 << 0,
    TDEventTypeTrackFirst = 1 << 1,
    TDEventTypeTrackUpdate = 1 << 2,
    TDEventTypeTrackOverwrite = 1 << 3,
    TDEventTypeUserSet = 1 << 4,
    TDEventTypeUserUnset = 1 << 5,
    TDEventTypeUserAdd = 1 << 6,
    TDEventTypeUserDel = 1 << 7,
    TDEventTypeUserSetOnce = 1 << 8,
    TDEventTypeUserAppend = 1 << 9,
    TDEventTypeUserUniqueAppend = 1 << 10,
    TDEventTypeAll = 0xFFFFFFFF,
};

FOUNDATION_EXTERN NSString * const TD_BACKGROUND_DURATION;

typedef NSString *kEDEventTypeName;

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_DEL;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_ADD;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_SET;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_SETONCE;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_UNSET;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_APPEND;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_USER_UNIQ_APPEND;

typedef NS_OPTIONS(NSInteger, TDEventTimeValueType) {
    TDEventTimeValueTypeNone = 0,
    TDEventTimeValueTypeTimeOnly = 1 << 0,
    TDEventTimeValueTypeTimeAndZone = 1 << 1,
};

@interface TDBaseEvent : NSObject<TDEventPropertyValidating>
@property (nonatomic, assign) TDEventType eventType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *distinctId;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong, readonly) NSDateFormatter *timeFormatter;

@property (nonatomic, assign) TDEventTimeValueType timeValueType;
@property (nonatomic, strong) NSMutableDictionary *properties;

@property (nonatomic, assign) BOOL immediately;
@property (nonatomic, assign) BOOL isDebug;

@property (atomic, assign, getter=isTrackPause) BOOL trackPause;

@property (nonatomic, assign) BOOL isEnabled;

@property (atomic, assign) BOOL isOptOut;

- (instancetype)initWithType:(TDEventType)type;

- (void)validateWithError:(NSError **)error;

- (NSMutableDictionary *)jsonObject;

- (NSMutableDictionary *)formatDateWithDict:(NSDictionary *)dict;

- (NSString *)eventTypeString;

+ (TDEventType)typeWithTypeString:(NSString *)typeString;

@end

NS_ASSUME_NONNULL_END
