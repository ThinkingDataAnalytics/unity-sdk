//
//  TAUserEventSetOnce.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TAUserEventSetOnce.h"

@implementation TAUserEventSetOnce

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserSetOnce;
    }
    return self;
}

@end
