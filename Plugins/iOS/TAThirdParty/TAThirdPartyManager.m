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
#import "TAKochavaSyncData.h"


typedef NS_OPTIONS(NSInteger, TDThirdPartyType) {
    TDThirdPartyTypeNone               = 0,
    TDThirdPartyTypeAppsFlyer          = 1 << 0,
    TDThirdPartyTypeIronSource         = 1 << 1,
    TDThirdPartyTypeAdjust             = 1 << 2,
    TDThirdPartyTypeBranch             = 1 << 3,
    TDThirdPartyTypeTopOn              = 1 << 4,
    TDThirdPartyTypeTracking           = 1 << 5,
    TDThirdPartyTypeTradPlus           = 1 << 6,
    TDThirdPartyTypeAppLovin           = 1 << 7,
    TDThirdPartyTypeKochava            = 1 << 8,
    TDThirdPartyTypeTalkingData        = 1 << 9,
    TDThirdPartyTypeFirebase           = 1 << 10,
};

static NSMutableDictionary *_thirdPartyManagerMap;

static NSString * const KEY_THIRD_PARTY_CLASS_NAME = @"libClass";
static NSString * const KEY_TA_PLUGIN_CLASS_NAME = @"taThirdClass";
static NSString * const KEY_ERROR_MESSAGE = @"errorMes";

char * kThinkingServices_service __attribute((used, section("__DATA, ThinkingServices"))) = "{ \"TAThirdPartyProtocol\" : \"TAThirdPartyManager\"}";
@interface TAThirdPartyManager()<TAThirdPartyProtocol>

@end


@implementation TAThirdPartyManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _thirdPartyManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance
{
    [self enableThirdPartySharing:type instance:instance property:@{}];
}

- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property
{
    NSArray<NSDictionary *> *thirdPartyList = [self _getThridInfoWithType:type];
    
    for (NSInteger i = 0; i < thirdPartyList.count; i++) {
        NSDictionary *info = thirdPartyList[i];
        
        NSString *libClass = info[KEY_THIRD_PARTY_CLASS_NAME];
        NSString *taThirdClass = info[KEY_TA_PLUGIN_CLASS_NAME];
        NSString *errorMes = info[KEY_ERROR_MESSAGE];
        
        if (!NSClassFromString(libClass)) {
            NSLog(@"[ThinkingData][Error] %@", errorMes);
        } else {
            id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:taThirdClass];
            if (!syncData) {
                syncData = [NSClassFromString(taThirdClass) new];
                [_thirdPartyManagerMap setObject:syncData forKey:taThirdClass];
            }
            [syncData syncThirdData:instance property:[property copy]];
            NSLog(@"[ThinkingData][Info] %@ , SyncThirdData Success", NSClassFromString(libClass));
        }
    }
}

- (NSArray<NSDictionary *> *)_getThridInfoWithType:(NSNumber *)type {
    NSInteger typeNum = type.integerValue;
    
    NSMutableArray<NSDictionary *> *mutableArray = [NSMutableArray array];
    
    if (typeNum & TDThirdPartyTypeAppsFlyer) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"AppsFlyerLib",
            KEY_TA_PLUGIN_CLASS_NAME: @"TAAppsFlyerSyncData",
            KEY_ERROR_MESSAGE: @"AppsFlyer Data synchronization exception: not installed AppsFlyer SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeIronSource) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"IronSource",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAIronSourceSyncData",
            KEY_ERROR_MESSAGE: @"IronSource Data synchronization exception: not installed IronSource SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeAdjust) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"Adjust",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAAdjustSyncData",
            KEY_ERROR_MESSAGE: @"Adjust Data synchronization exception: not installed Adjust SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeBranch) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"Branch",
            KEY_TA_PLUGIN_CLASS_NAME:@"TABranchSyncData",
            KEY_ERROR_MESSAGE: @"Branch Data synchronization exception: not installed Branch SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeTopOn) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"ATAPI",
            KEY_TA_PLUGIN_CLASS_NAME:@"TATopOnSyncData",
            KEY_ERROR_MESSAGE: @"TopOn Data synchronization exception: not installed TopOn SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeTracking) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"Tracking",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAReYunSyncData",
            KEY_ERROR_MESSAGE: @"ReYun Data synchronization exception:  Data synchronization exception: not installed SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeTradPlus) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"TradPlus",
            KEY_TA_PLUGIN_CLASS_NAME:@"TATradPlusSyncData",
            KEY_ERROR_MESSAGE: @"TradPlus Data synchronization exception: not installed TradPlus SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeAppLovin) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"ALSdk",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAAppLovinSyncData",
            KEY_ERROR_MESSAGE: @"AppLovin Data synchronization exception: not installed AppLovin SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeKochava) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"KVATracker",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAKochavaSyncData",
            KEY_ERROR_MESSAGE: @"Kochava Data synchronization exception: not installed Kochava SDK"
        }];
    }
    
    if (typeNum & TDThirdPartyTypeFirebase) {
        [mutableArray addObject:@{
            KEY_THIRD_PARTY_CLASS_NAME: @"FIRAnalytics",
            KEY_TA_PLUGIN_CLASS_NAME:@"TAFirebaseSyncData",
            KEY_ERROR_MESSAGE: @"FIREBASE Data synchronization exception: not installed FIRAnalytics SDK"
        }];
    }
    
    return [mutableArray copy];
}

@end
