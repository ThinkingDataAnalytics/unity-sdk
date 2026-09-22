//
//  TAUserEventSet.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventSet.h"

@implementation TDUserEventSet

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserSet;
    }
    return self;
}

@end
