//
//  TAThirdPartyManager.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import "TAThirdPartyManager.h"
#import "TAAppsFlyerSyncData.h"
#import "TAIronSourceSyncData.h"
#import "TAAdjustSyncData.h"
#import "TABranchSyncData.h"
#import "TATopOnSyncData.h"
#import "TAReYunSyncData.h"
#import "TATradPlusSyncData.h"

static NSMutableDictionary *_thirdPartyManagerMap;

@implementation TAThirdPartyManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _thirdPartyManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id<TAThinkingTrackProtocol>)instance
{
    [self enableThirdPartySharing:type instance:instance property:@{}];
}

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property
{
    
    if ((type & TAThirdPartyShareTypeAPPSFLYER) == TAThirdPartyShareTypeAPPSFLYER) {
        if (!NSClassFromString(@"AppsFlyerLib")) {
            NSLog(@"AppsFlyer数据同步异常: 未安装AppsFlyer SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TAAppsFlyerSyncData"];
            if (!syncData) {
                syncData = [TAAppsFlyerSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TAAppsFlyerSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];
        }
    }
    
    if ((type & TAThirdPartyShareTypeIRONSOURCE) == TAThirdPartyShareTypeIRONSOURCE) {
        if (!NSClassFromString(@"IronSource")) {
            NSLog(@"IronSource数据同步异常: 未安装IronSource SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TAIronSourceSyncData"];
            if (!syncData) {
                syncData = [TAIronSourceSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TAIronSourceSyncData"];
            }
            [syncData syncThirdData:instance];
        }

    }
    
    if ((type & TAThirdPartyShareTypeADJUST) == TAThirdPartyShareTypeADJUST) {
        if (!NSClassFromString(@"Adjust")) {
            NSLog(@"Adjust数据同步异常: 未安装Adjust SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TAAdjustSyncData"];
            if (!syncData) {
                syncData = [TAAdjustSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TAAdjustSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];
        }
    }
    
    if ((type & TAThirdPartyShareTypeBRANCH) == TAThirdPartyShareTypeBRANCH) {
        if (!NSClassFromString(@"Branch")) {
            NSLog(@"Branch数据同步异常: 未安装Branch SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TABranchSyncData"];
            if (!syncData) {
                syncData = [TABranchSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TABranchSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];
        }
    }
    
    if ((type & TAThirdPartyShareTypeTOPON) == TAThirdPartyShareTypeTOPON) {
        if (!NSClassFromString(@"ATAPI")) {
            NSLog(@"TopOn数据同步异常: 未安装TopOn SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TATopOnSyncData"];
            if (!syncData) {
                syncData = [TATopOnSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TATopOnSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];

        }
    }
    
    if ((type & TAThirdPartyShareTypeTRACKING) == TAThirdPartyShareTypeTRACKING) {
        if (!NSClassFromString(@"Tracking")) {
            NSLog(@"热云数据同步异常: 未安装热云 SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TAReYunSyncData"];
            if (!syncData) {
                syncData = [TAReYunSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TAReYunSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];
        }
    }
    
    if ((type & TAThirdPartyShareTypeTRADPLUS) == TAThirdPartyShareTypeTRADPLUS) {
        if (!NSClassFromString(@"TradPlus")) {
            NSLog(@"TradPlus数据同步异常: 未安装TradPlus SDK");
        }else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TATradPlusSyncData"];
            if (!syncData) {
                syncData = [TATradPlusSyncData new];
                [_thirdPartyManagerMap setObject:syncData forKey:@"TATradPlusSyncData"];
            }
            [syncData syncThirdData:instance property:[property copy]];
        }
    }
}

@end
