//
//  TDAppLaunchReason.h
//  ThinkingSDK
//
//  Created by wwango on 2021/11/17.
//  Copyright © 2021 thinkingdata. All rights reserved.


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSDictionary *appPushClickDic;

@interface TDAppLaunchReason : NSObject

@property(nonatomic, copy) NSDictionary *appLaunchParams;

+ (TDAppLaunchReason *)sharedInstance;

- (void)clearAppLaunchParams;

+ (void)td_ops_push_click:(NSDictionary *)userInfo;

+ (NSDictionary*)getAppPushDic;

+ (void)clearAppPushParams;

@end

NS_ASSUME_NONNULL_END
