//
//  TAUserEventSet.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TAUserEventSet.h"

@implementation TAUserEventSet

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserSet;
    }
    return self;
}

@end
