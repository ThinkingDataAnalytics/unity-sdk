//
//  TATrackTimer.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TDTrackTimer.h"
#import "TDTrackTimerItem.h"
#import "TDThreadSafeDictionary.h"
#import "TDCommonUtil.h"

@interface TDTrackTimer ()
@property (nonatomic, strong) TDThreadSafeDictionary *events;

@end

@implementation TDTrackTimer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.events = [TDThreadSafeDictionary dictionary];
    }
    return self;
}

- (void)trackEvent:(NSString *)eventName withSystemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return;
    }
    TDTrackTimerItem *item = [[TDTrackTimerItem alloc] init];
    item.beginTime = systemUptime ?: [TDCommonUtil uptime];
    self.events[eventName] = item;
}

- (void)enterForegroundWithSystemUptime:(NSTimeInterval)systemUptime {
    NSArray *keys = [self.events allKeys];
    for (NSString *key in keys) {
        TDTrackTimerItem *item = self.events[key];
        item.beginTime = systemUptime;
        if (item.enterBackgroundTime == 0) {
            item.backgroundDuration = 0;
        } else {
            item.backgroundDuration = systemUptime - item.enterBackgroundTime + item.backgroundDuration;
        }
    }
}

- (void)enterBackgroundWithSystemUptime:(NSTimeInterval)systemUptime {
    NSArray *keys = [self.events allKeys];
    for (NSString *key in keys) {
        TDTrackTimerItem *item = self.events[key];
        item.enterBackgroundTime = systemUptime;
        item.foregroundDuration = systemUptime - item.beginTime + item.foregroundDuration;
    }
}

- (NSTimeInterval)foregroundDurationOfEvent:(NSString *)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return 0;
    }
    TDTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return 0;
    }
    
    if (isActive) {
        NSTimeInterval duration = systemUptime - item.beginTime + item.foregroundDuration;
        return [self validateDuration:duration eventName:eventName];
    } else {
        return [self validateDuration:item.foregroundDuration eventName:eventName];
    }
    
}

- (NSTimeInterval)backgroundDurationOfEvent:(NSString *)eventName isActive:(BOOL)isActive systemUptime:(NSTimeInterval)systemUptime {
    if (!eventName.length) {
        return 0;
    }
    TDTrackTimerItem *item = self.events[eventName];
    if (!item) {
        return 0;
    }
    if (isActive) {
        return [self validateDuration:item.backgroundDuration eventName:eventName];
    } else {
        NSTimeInterval duration = 0;
        if (item.enterBackgroundTime == 0) {
            duration = 0;
        } else {
            duration = systemUptime - item.enterBackgroundTime + item.backgroundDuration;
        }
        return [self validateDuration:duration eventName:eventName];
    }
}

- (void)removeEvent:(NSString *)eventName {
    [self.events removeObjectForKey:eventName];
}

- (BOOL)isExistEvent:(NSString *)eventName {
    return self.events[eventName] != nil;
}

- (void)clear {
    [self.events removeAllObjects];
}

//MARK: - Private Methods

- (NSTimeInterval)validateDuration:(NSTimeInterval)duration eventName:(NSString *)eventName {
    NSInteger max = 3600 * 24;
    if (duration >= max) {
        return max;
    }
    
    return duration;
}

@end


