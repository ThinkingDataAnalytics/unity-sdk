//
//  TDNotificationManager+Core.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/6/27.
//

#import "TDNotificationManager+Core.h"

NSString * const kCoreNotificationNameCalibratedTimeSuccess = @"kCoreNotificationNameCalibratedTimeSuccess";
NSString * const kCoreNotificationParamsCalibratedTimeNow = @"now";

@implementation TDNotificationManager (Core)

+ (void)postCoreNotificationCalibratedTimeSuccess:(NSDate *)now {
    if (![now isKindOfClass:NSDate.class]) {
        return;
    }
    [self postNotificationName:kCoreNotificationNameCalibratedTimeSuccess object:nil userInfo:@{
        kCoreNotificationParamsCalibratedTimeNow: now
    }];
}

@end
