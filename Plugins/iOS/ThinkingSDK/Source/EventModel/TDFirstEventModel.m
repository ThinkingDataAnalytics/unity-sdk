#import "TDFirstEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDFirstEventModel

- (instancetype)initWithEventName:(NSString *)eventName {
    return [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_FIRST];
}

- (instancetype)initWithEventName:(NSString *)eventName firstCheckID:(NSString *)firstCheckID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_FIRST]) {
        self.extraID = firstCheckID;
    }
    return self;
}

@end
