#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, TimeValueType) {
    TDTimeValueTypeNone      = 0,
    TDTimeValueTypeTimeOnly  = 1 << 0,
    TDTimeValueTypeAll       = 1 << 1,
};

typedef NSString *kEDEventTypeName;

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_FIRST;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE;

@interface TDEventModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *eventName;
@property (nonatomic, copy, readonly) kEDEventTypeName eventType; // Default is TD_EVENT_TYPE_TRACK

@property (nonatomic, strong) NSDictionary *properties;

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone * _Nullable)timeZone;

@end

NS_ASSUME_NONNULL_END
