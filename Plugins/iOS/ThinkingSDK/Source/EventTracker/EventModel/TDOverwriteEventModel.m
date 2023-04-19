//
//  TDOverwriteEventModel.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDOverwriteEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDOverwriteEventModel

- (instancetype)initWithEventName:(NSString *)eventName eventID:(NSString *)eventID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
        self.extraID = eventID;
    }
    return self;
}

@end
