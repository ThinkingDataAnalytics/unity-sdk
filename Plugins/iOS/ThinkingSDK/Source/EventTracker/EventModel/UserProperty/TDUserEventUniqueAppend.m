//
//  TAUserEventUniqueAppend.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventUniqueAppend.h"

@implementation TDUserEventUniqueAppend

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserUniqueAppend;
    }
    return self;
}

@end
