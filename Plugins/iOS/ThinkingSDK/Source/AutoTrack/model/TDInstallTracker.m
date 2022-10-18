//
//  TDInstallTracker.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDInstallTracker.h"
#import "TDDeviceInfo.h"

@implementation TDInstallTracker

- (BOOL)isOneTime {
    return YES;
}

- (BOOL)additionalCondition {
    return [TDDeviceInfo sharedManager].isFirstOpen;
}

@end
