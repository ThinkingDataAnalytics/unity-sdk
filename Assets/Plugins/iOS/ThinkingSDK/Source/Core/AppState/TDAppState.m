//
//  TDAppState.m
//  ThinkingSDK
//
//  Created by wwango on 2021/9/24.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAppState.h"

NSString *_td_lastKnownState;

@implementation TDAppState

+ (TDAppState *)_appState {
    static dispatch_once_t onceToken;
    static TDAppState *appState;
    
    dispatch_once(&onceToken, ^{
        appState = [TDAppState new];
    });
    
    return appState;
}

+ (nullable UIApplication *)sharedApplication {
    if ([self runningInAppExtension]) {
      return nil;
    }
    return [[UIApplication class] performSelector:@selector(sharedApplication)];
}

+ (BOOL)runningInAppExtension
{
  return [[[[NSBundle mainBundle] bundlePath] pathExtension] isEqualToString:@"appex"];
}

+ (NSString *)currentAppState
{
    static NSDictionary *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @{
            @(UIApplicationStateActive): TDApplicationStateActive,
            @(UIApplicationStateBackground): TDApplicationStateBackground
        };
    });
    
    if ([self runningInAppExtension]) {
        return TDApplicationStateExtension;
    }
    
    return states[@([TDAppState sharedApplication].applicationState)] ?: TDApplicationStateUnknown;
}

+ (NSString *)lastAppState {
    return _td_lastKnownState;
}

+ (BOOL)isStateBackground {
    return [_td_lastKnownState isEqualToString:TDApplicationStateBackground];
}

+ (void)load {
    for (NSString *name in @[UIApplicationDidBecomeActiveNotification,
                             UIApplicationDidEnterBackgroundNotification,
                             UIApplicationDidFinishLaunchingNotification,
                             UIApplicationWillResignActiveNotification,
                             UIApplicationWillEnterForegroundNotification,
                             UIApplicationDidFinishLaunchingNotification]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:[TDAppState _appState]
                                                 selector:@selector(handleAppStateDidChange:)
                                                     name:name
                                                   object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:[TDAppState _appState]
                                             selector:@selector(handleMemoryWarning)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)handleAppStateDidChange:(NSNotification *)notification
{
    NSString *newState;
    
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {

    } else if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        newState = TDApplicationStateInactive;
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        newState = TDApplicationStateBackground;
    } else {
        newState = [TDAppState currentAppState];
    }
    
    if (![newState isEqualToString:_td_lastKnownState]) {
        _td_lastKnownState = newState;
    }
}

- (void)handleMemoryWarning
{
    
}

@end
