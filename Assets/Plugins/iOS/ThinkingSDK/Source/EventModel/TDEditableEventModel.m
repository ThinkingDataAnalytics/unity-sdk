#import "TDEditableEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDEditableEventModel ()

@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) kEDEventTypeName eventType;

@end

@implementation TDEditableEventModel
@synthesize eventName = _eventName;
@synthesize eventType = _eventType;

- (instancetype)initWithEventName:(NSString *)eventName eventID:(NSString *)eventID {
    NSAssert(nil, @"Init with subClass: TDUpdateEventModel or TDOverwriteEventModel!");
    return nil;
}

@end

@implementation TDUpdateEventModel

- (instancetype)initWithEventName:(NSString *)eventName
                          eventID:(NSString *)eventID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_UPDATE]) {
        self.extraID = eventID;
    }
    return self;
}

@end

@implementation TDOverwriteEventModel

- (instancetype)initWithEventName:(NSString *)eventName
                          eventID:(NSString *)eventID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        self.extraID = eventID;
    }
    return self;
}

@end
