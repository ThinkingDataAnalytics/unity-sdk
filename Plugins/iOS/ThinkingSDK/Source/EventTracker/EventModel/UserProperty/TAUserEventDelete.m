//
//  TAUserEventDelete.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TAUserEventDelete.h"

@implementation TAUserEventDelete

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserDel;
    }
    return self;
}

@end
