#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *kEDEventTypeName;

FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_FIRST;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_UPDATE;
FOUNDATION_EXTERN kEDEventTypeName const TD_EVENT_TYPE_TRACK_OVERWRITE;

@interface TDEventModel : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSString *eventName;
@property (nonatomic, copy, readonly) kEDEventTypeName eventType;
@property (nonatomic, strong) NSDictionary *properties;

- (void)configTime:(NSDate *)time timeZone:(NSTimeZone *)timeZone;

@end

NS_ASSUME_NONNULL_END
