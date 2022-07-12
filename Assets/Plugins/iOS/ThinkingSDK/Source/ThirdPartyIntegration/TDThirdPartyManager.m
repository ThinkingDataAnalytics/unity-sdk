//
//  TDThirdPartyManager.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import "TDThirdPartyManager.h"
#import "TDAppsFlyerSyncData.h"
#import "TDIronSourceSyncData.h"
#import "TDAdjustSyncData.h"
#import "TDBranchSyncData.h"
#import "TDTopOnSyncData.h"
#import "TDReYunSyncData.h"
#import "TDTradPlusSyncData.h"

static NSMutableDictionary *_thirdPartyManagerMap;

@implementation TDThirdPartyManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _thirdPartyManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance
{
    [self enableThirdPartySharing:type instance:instance property:@{}];
}

- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance property:(NSDictionary *)property
{
    
    if ((type & TDThirdPartyShareTypeAPPSFLYER) == TDThirdPartyShareTypeAPPSFLYER) {
        if (!NSClassFromString(@"AppsFlyerLib")) {
            NSLog(@"AppsFlyer数据同步异常: 未安装AppsFlyer SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDAppsFlyerSyncData"];
        if (!syncData) {
            syncData = [TDAppsFlyerSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDAppsFlyerSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TDThirdPartyShareTypeIRONSOURCE) == TDThirdPartyShareTypeIRONSOURCE) {
        if (!NSClassFromString(@"IronSource")) {
            NSLog(@"IronSource数据同步异常: 未安装IronSource SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDIronSourceSyncData"];
        if (!syncData) {
            syncData = [TDIronSourceSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDIronSourceSyncData"];
        }
        [syncData syncThirdData:instance];
    }
    
    if ((type & TDThirdPartyShareTypeADJUST) == TDThirdPartyShareTypeADJUST) {
        if (!NSClassFromString(@"Adjust")) {
            NSLog(@"Adjust数据同步异常: 未安装Adjust SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDAdjustSyncData"];
        if (!syncData) {
            syncData = [TDAdjustSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDAdjustSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TDThirdPartyShareTypeBRANCH) == TDThirdPartyShareTypeBRANCH) {
        if (!NSClassFromString(@"Branch")) {
            NSLog(@"Branch数据同步异常: 未安装Branch SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDBranchSyncData"];
        if (!syncData) {
            syncData = [TDBranchSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDBranchSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TDThirdPartyShareTypeTOPON) == TDThirdPartyShareTypeTOPON) {
        if (!NSClassFromString(@"ATAPI")) {
            NSLog(@"TopOn数据同步异常: 未安装TopOn SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDTopOnSyncData"];
        if (!syncData) {
            syncData = [TDTopOnSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDTopOnSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TDThirdPartyShareTypeTRACKING) == TDThirdPartyShareTypeTRACKING) {
        if (!NSClassFromString(@"Tracking")) {
            NSLog(@"热云数据同步异常: 未安装热云 SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDReYunSyncData"];
        if (!syncData) {
            syncData = [TDReYunSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDReYunSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }
    
    if ((type & TDThirdPartyShareTypeTRADPLUS) == TDThirdPartyShareTypeTRADPLUS) {
        if (!NSClassFromString(@"TradPlus")) {
            NSLog(@"TradPlus数据同步异常: 未安装TradPlus SDK");
            return;
        }
        id<TDThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:@"TDTradPlusSyncData"];
        if (!syncData) {
            syncData = [TDTradPlusSyncData new];
            [_thirdPartyManagerMap setObject:syncData forKey:@"TDTradPlusSyncData"];
        }
        [syncData syncThirdData:instance property:[property copy]];
    }

}

@end
