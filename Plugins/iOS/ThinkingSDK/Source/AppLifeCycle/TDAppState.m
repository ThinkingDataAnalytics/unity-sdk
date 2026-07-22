//
//  TDAppState.m
//  ThinkingSDK
//
//  Created by wwango on 2021/9/24.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDAppState.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

@implementation TDAppState

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TDAppState *appState;
    dispatch_once(&onceToken, ^{
        appState = [TDAppState new];
    });
    return appState;
}

+ (id)sharedApplication {
    
#if TARGET_OS_IOS

    if ([self runningInAppExtension]) {
      return nil;
    }
    return [[UIApplication class] performSelector:@selector(sharedApplication)];
    
#endif
    return nil;
}

+ (BOOL)runningInAppExtension {
#if TARGET_OS_IOS
    return [[[[NSBundle mainBundle] bundlePath] pathExtension] isEqualToString:@"appex"];
#endif
    return NO;
}

@end
