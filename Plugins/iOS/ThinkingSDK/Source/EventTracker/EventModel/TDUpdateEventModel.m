//
//  TDUpdateEventModel.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUpdateEventModel.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TDUpdateEventModel

- (instancetype)initWithEventName:(NSString *)eventName eventID:(NSString *)eventID {
    if (self = [self initWithEventName:eventName eventType:TD_EVENT_TYPE_TRACK_UPDATE]) {
        self.extraID = eventID;
    }
    return self;
}

@end
