//
//  TAUserEventDelete.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventDelete.h"

@implementation TDUserEventDelete

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserDel;
    }
    return self;
}

@end
