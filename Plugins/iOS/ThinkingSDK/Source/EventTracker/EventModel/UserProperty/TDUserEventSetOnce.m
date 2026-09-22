//
//  TAUserEventSetOnce.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventSetOnce.h"

@implementation TDUserEventSetOnce

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserSetOnce;
    }
    return self;
}

@end
