//
//  TDAppState.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/24.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TDApplicationStateActive @"active"
#define TDApplicationStateInactive @"inactive"
#define TDApplicationStateBackground @"background"
#define TDApplicationStateExtension @"extension"
#define TDApplicationStateUnknown @"unknown"

NS_ASSUME_NONNULL_BEGIN

@interface TDAppState : NSObject

+ (NSString *)lastAppState;

+ (BOOL)isStateBackground;

+ (NSString *)currentAppState;

+ (nullable UIApplication *)sharedApplication;

@end

NS_ASSUME_NONNULL_END
