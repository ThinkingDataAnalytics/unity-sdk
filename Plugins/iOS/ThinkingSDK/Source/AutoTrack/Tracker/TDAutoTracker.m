//
//  TDAutoTracker.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAutoTracker.h"
#import "ThinkingAnalyticsSDKPrivate.h"

#if __has_include(<ThinkingDataCore/ThinkingDataCore.h>)
#import <ThinkingDataCore/ThinkingDataCore.h>
#else
#import "ThinkingDataCore.h"
#endif

@interface TDAutoTracker ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *trackCounts;

@end

@implementation TDAutoTracker

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isOneTime = NO;
        _autoFlush = YES;
        _additionalCondition = YES;
        
        self.trackCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)trackWithInstanceTag:(NSString *)instanceName event:(TDAutoTrackEvent *)event params:(NSDictionary *)params {
    if ([self canTrackWithInstanceToken:instanceName]) {
        ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK instanceWithAppid:instanceName];
#ifdef DEBUG
        if (!instance) {
            @throw [NSException exceptionWithName:@"Thinkingdata Exception" reason:[NSString stringWithFormat:@"check this thinking instance, instanceTag: %@", instanceName] userInfo:nil];
        }
#endif
        [instance autoTrackWithEvent:event properties:params];
                
        if (self.autoFlush) [instance innerFlush];
        
        if ([[self class] isEqual:NSClassFromString(@"TDInstallTracker")]) {
            [TDNotificationManager postAnalyticsAppInstallEventWithAppId:instanceName];
        }
    }
}

- (BOOL)canTrackWithInstanceToken:(NSString *)token {
    
    if (!self.additionalCondition) {
        return NO;
    }
    
    NSInteger trackCount = [self.trackCounts[token] integerValue];
    
    if (self.isOneTime && trackCount >= 1) {
        return NO;
    }
    
    if (self.isOneTime) {
        trackCount++;
        self.trackCounts[token] = @(trackCount);
    }
    
    return YES;
}

@end
