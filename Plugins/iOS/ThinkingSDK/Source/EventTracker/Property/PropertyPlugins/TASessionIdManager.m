//
//  TASessionIdManager.m
//  ThinkingSDK
//
//  Created by Charles on 6.12.22.
//

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
#import "TASessionIdManager.h"
#import "TAAppLifeCycle.h"
#import "TDAppState.h"
#import "ThinkingAnalyticsSDKPrivate.h"

@implementation TASessionIdManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerAppLifeCycleListener];
    }
    return self;
}

- (void)registerAppLifeCycleListener {
    if ([TDAppState runningInAppExtension]) {
        return;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IOS

    [notificationCenter addObserver:self selector:@selector(appStateWillChangeNotification:) name:kTAAppLifeCycleStateWillChangeNotification object:nil];
    
#endif
}


- (void)appStateWillChangeNotification:(NSNotification *)notification {
    TAAppLifeCycleState newState = [[notification.userInfo objectForKey:kTAAppLifeCycleNewStateKey] integerValue];
    TAAppLifeCycleState oldState = [[notification.userInfo objectForKey:kTAAppLifeCycleOldStateKey] integerValue];

    if (oldState == TAAppLifeCycleStateInit) {
        return;
    }
    
    if (newState == TAAppLifeCycleStateStart) {
        @synchronized ([self class]) {
            [self updateSessionId];
        }
    }
}

- (void)updateSessionId {
//    NSMutableDictionary *dic = [ThinkingAnalyticsSDK _getAllInstances];
//    for (NSString *instanceToken in dic.allKeys) {
//        ThinkingAnalyticsSDK *instance = dic[instanceToken];
//        if ([instance isKindOfClass:[ThinkingAnalyticsSDK class]]) {
//            [instance.sessionidPlugin updateSessionId];
//        }
//    }
}

@end
