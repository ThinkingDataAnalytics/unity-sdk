//
//  TDStartTracker.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDStartTracker.h"

@implementation TDColdStartTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isOneTime = YES;
    }
    return self;
}

@end

@implementation TDHotStartTracker

@end
 
