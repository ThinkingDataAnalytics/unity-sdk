//
//  TABaseEvent.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import <Foundation/Foundation.h>
#import "TAPropertyValidator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString * kTAEventType;

typedef NS_OPTIONS(NSUInteger, TAEventType) {
    TAEventTypeNone = 0,
    TAEventTypeTrack = 1 << 0,
    TAEventTypeTrackFirst = 1 << 1,
    TAEventTypeTrackUpdate = 1 << 2,
    TAEventTypeTrackOverwrite = 1 << 3,
    TAEventTypeUserSet = 1 << 4,
    TAEventTypeUserUnset = 1 << 5,
    TAEventTypeUserAdd = 1 << 6,
    TAEventTypeUserDel = 1 << 7,
    TAEventTypeUserSetOnce = 1 << 8,
    TAEventTypeUserAppend = 1 << 9,
    TAEventTypeUserUniqueAppend = 1 << 10,
    TAEventTypeAll = 0xFFFFFFFF,
};

//extern kTAEventType const kTAEventTypeTrack;
//extern kTAEventType const kTAEventTypeTrackFirst;
//extern kTAEventType const kTAEventTypeTrackUpdate;
//extern kTAEventType const kTAEventTypeTrackOverwrite;
//extern kTAEventType const kTAEventTypeUserSet;
//extern kTAEventType const kTAEventTypeUserUnset;
//extern kTAEventType const kTAEventTypeUserAdd;
//extern kTAEventType const kTAEventTypeUserDel;
//extern kTAEventType const kTAEventTypeUserSetOnce;
//extern kTAEventType const kTAEventTypeUserAppend;
//extern kTAEventType const kTAEventTypeUserUniqueAppend;

typedef NS_OPTIONS(NSInteger, TAEventTimeValueType) {
    TAEventTimeValueTypeNone = 0,
    TAEventTimeValueTypeTimeOnly = 1 << 0,
    TAEventTimeValueTypeTimeAndZone = 1 << 1,
};

@interface TABaseEvent : NSObject<TAEventPropertyValidating>
@property (nonatomic, assign) TAEventType eventType;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *distinctId;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSTimeZone *timeZone;
@property (nonatomic, strong, readonly) NSDateFormatter *timeFormatter;

@property (nonatomic, assign) TAEventTimeValueType timeValueType;
@property (nonatomic, strong) NSMutableDictionary *properties;

@property (nonatomic, assign) BOOL immediately;

@property (atomic, assign, getter=isTrackPause) BOOL trackPause;

@property (nonatomic, assign) BOOL isEnabled;

@property (atomic, assign) BOOL isOptOut;

- (instancetype)initWithType:(TAEventType)type;

- (void)validateWithError:(NSError **)error;

- (NSMutableDictionary *)jsonObject;

- (NSMutableDictionary *)formatDateWithDict:(NSDictionary *)dict;

- (NSString *)eventTypeString;

+ (TAEventType)typeWithTypeString:(NSString *)typeString;

@end

NS_ASSUME_NONNULL_END
