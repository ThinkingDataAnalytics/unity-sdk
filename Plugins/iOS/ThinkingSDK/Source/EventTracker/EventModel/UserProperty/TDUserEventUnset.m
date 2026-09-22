//
//  TAUserEventUnset.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventUnset.h"

@implementation TDUserEventUnset

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserUnset;
    }
    return self;
}

@end
