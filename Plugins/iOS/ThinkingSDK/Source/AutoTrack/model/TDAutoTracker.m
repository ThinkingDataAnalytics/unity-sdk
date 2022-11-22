//
//  TDAutoTracker.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAutoTracker.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@interface TDAutoTracker ()

// 执行次数
@property (atomic, assign) int trackCount;

@end

@implementation TDAutoTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOneTime = NO;
        _trackCount = 0;
        _autoFlush = YES;
        _additionalCondition = YES;
    }
    return self;
}

- (void)trackWithInstanceTag:(NSString *)instanceName eventName:(NSString *)eventName params:(NSDictionary *)params {
    if ([self canTrack]) {
        ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:instanceName];
#ifdef DEBUG
        if (!instance) {
            @throw [NSException exceptionWithName:@"Thinkingdata Exception" reason:[NSString stringWithFormat:@"check this thinking instance, instanceTag: %@", instanceName] userInfo:nil];
        }
#endif
        [instance autotrack:eventName properties:params withTime:nil];
        if (self.autoFlush) [instance flush];
    }
}

- (BOOL)canTrack {
    
    if (!self.additionalCondition) {
        return NO;
    }
    
    if (self.isOneTime && _trackCount >= 1) {
        return NO;
    }
    
    if (self.isOneTime) _trackCount ++;
    
    return YES;
}

@end
