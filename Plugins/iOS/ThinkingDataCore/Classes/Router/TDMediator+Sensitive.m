//
//  TDMediator+Sensitive.m
//  ThinkingDataCore
//
//  Created by liulongbing on 2025/5/28.
//

#import "TDMediator+Sensitive.h"

NSString * const kTDMediatorTargetSensitive = @"Sensitive";

NSString * const kTDMediatorTargetSensitiveActionNativeGetSensitiveProperties = @"nativeGetSensitiveProperties";

@implementation TDMediator (Sensitive)

- (NSDictionary *)tdGetSensitiveProperties{
    NSDictionary *dict = [[TDMediator sharedInstance] performTarget:kTDMediatorTargetSensitive action:kTDMediatorTargetSensitiveActionNativeGetSensitiveProperties params:nil shouldCacheTarget:YES];
    return dict;
}

@end
