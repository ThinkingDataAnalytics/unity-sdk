//
//  TDAppState.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/24.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDAppState : NSObject
/// Whether to start in the background. When the app is woken up by silently pushing the background, or when the location change wakes up the app, value = YES. (thread safe)
@property (atomic, assign) BOOL relaunchInBackground;

/// Whether the current app is in the foreground
@property (atomic, assign) BOOL isActive;

+ (instancetype)shareInstance;

+ (id)sharedApplication;

+ (BOOL)runningInAppExtension;

@end

NS_ASSUME_NONNULL_END
