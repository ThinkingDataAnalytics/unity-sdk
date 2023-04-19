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

- (void)trackWithInstanceTag:(NSString *)instanceName event:(TAAutoTrackEvent *)event params:(NSDictionary *)params {
    if ([self canTrackWithInstanceToken:instanceName]) {
        ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:instanceName];
#ifdef DEBUG
        if (!instance) {
            @throw [NSException exceptionWithName:@"Thinkingdata Exception" reason:[NSString stringWithFormat:@"check this thinking instance, instanceTag: %@", instanceName] userInfo:nil];
        }
#endif
        [instance autoTrackWithEvent:event properties:params];
                
        if (self.autoFlush) [instance flush];
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
