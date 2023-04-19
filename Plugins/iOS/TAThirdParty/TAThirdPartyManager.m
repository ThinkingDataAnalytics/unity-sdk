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


 typedef NS_OPTIONS(NSInteger, TAInnerThirdPartyShareType) {
     TAInnerThirdPartyShareTypeNONE               = 0,
     TAInnerThirdPartyShareTypeAPPSFLYER          = 1 << 0,
     TAInnerThirdPartyShareTypeIRONSOURCE         = 1 << 1,
     TAInnerThirdPartyShareTypeADJUST             = 1 << 2,
     TAInnerThirdPartyShareTypeBRANCH             = 1 << 3,
     TAInnerThirdPartyShareTypeTOPON              = 1 << 4,
     TAInnerThirdPartyShareTypeTRACKING           = 1 << 5,
     TAInnerThirdPartyShareTypeTRADPLUS           = 1 << 6,
     TAInnerThirdPartyShareTypeAPPLOVIN           = 1 << 7,
     TAInnerThirdPartyShareTypeKOCHAVA            = 1 << 8,
     TAInnerThirdPartyShareTypeTALKINGDATA        = 1 << 9,
     TAInnerThirdPartyShareTypeFIREBASE           = 1 << 10,
     
 };

static NSMutableDictionary *_thirdPartyManagerMap;

// Register a third-party data collection service, and when the APP starts, it will start from the data area
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

- (void)enableThirdPartySharing:(NSNumber *)typee instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property
{
    NSDictionary *info = [self _getThridInfoWithType:typee];
    
    NSString *libClass = info[@"libClass"];
    NSString *taThirdClass = info[@"taThirdClass"];
    NSString *errorMes = info[@"errorMes"];
    
    if (!NSClassFromString(libClass)) {
        NSLog(@"[THINKING] %@", errorMes);
    }else {
        id<TAThirdPartySyncProtocol> syncData = [_thirdPartyManagerMap objectForKey:taThirdClass];
        if (!syncData) {
            syncData = [NSClassFromString(taThirdClass) new];
            [_thirdPartyManagerMap setObject:syncData forKey:taThirdClass];
        }
        [syncData syncThirdData:instance property:[property copy]];
        NSLog(@"[THINKING] %@ , SyncThirdData Success", NSClassFromString(libClass));
    }
}




- (NSDictionary *)_getThridInfoWithType:(NSNumber *)typee {
    
    static NSDictionary *_ta_ThridInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _ta_ThridInfo = @{
            @(TAInnerThirdPartyShareTypeAPPSFLYER):@{
         
                   @"libClass": @"AppsFlyerLib",
                   @"taThirdClass":@"TAAppsFlyerSyncData",
                   @"errorMes":@"AppsFlyer Data synchronization exception: not installed AppsFlyer SDK"
           
            },
            @(TAInnerThirdPartyShareTypeIRONSOURCE):@{
           
                   @"libClass": @"IronSource",
                   @"taThirdClass":@"TAIronSourceSyncData",
                   @"errorMes": @"IronSource Data synchronization exception: not installed IronSource SDK"
     
            },
            @(TAInnerThirdPartyShareTypeADJUST):@{
  
                   @"libClass": @"Adjust",
                   @"taThirdClass":@"TAAdjustSyncData",
                   @"errorMes": @"Adjust Data synchronization exception: not installed Adjust SDK"
 
            },
            @(TAInnerThirdPartyShareTypeBRANCH):@{
  
                   @"libClass": @"Branch",
                   @"taThirdClass":@"TABranchSyncData",
                   @"errorMes": @"Branch Data synchronization exception: not installed Branch SDK"
 
            },
            @(TAInnerThirdPartyShareTypeTOPON):@{
  
                   @"libClass": @"ATAPI",
                   @"taThirdClass":@"TATopOnSyncData",
                   @"errorMes": @"TopOn Data synchronization exception: not installed TopOn SDK"
 
            },
            @(TAInnerThirdPartyShareTypeTRACKING):@{
  
                   @"libClass": @"Tracking",
                   @"taThirdClass":@"TAReYunSyncData",
                   @"errorMes": @"ReYun Data synchronization exception:  Data synchronization exception: not installed SDK"
 
            },
            @(TAInnerThirdPartyShareTypeTRADPLUS):@{
  
                   @"libClass": @"TradPlus",
                   @"taThirdClass":@"TATradPlusSyncData",
                   @"errorMes": @"TradPlus Data synchronization exception: not installed TradPlus SDK"
 
            },
            @(TAInnerThirdPartyShareTypeAPPLOVIN):@{
  
                   @"libClass": @"ALSdk",
                   @"taThirdClass":@"TAAppLovinSyncData",
                   @"errorMes": @"AppLovin Data synchronization exception: not installed AppLovin SDK"
 
            },
            @(TAInnerThirdPartyShareTypeKOCHAVA):@{
  
                   @"libClass": @"KVATracker",
                   @"taThirdClass":@"TAKochavaSyncData",
                   @"errorMes": @"Kochava Data synchronization exception: not installed Kochava SDK"
 
            },
            @(TAInnerThirdPartyShareTypeFIREBASE):@{
  
                   @"libClass": @"FIRAnalytics",
                   @"taThirdClass":@"TAFirebaseSyncData",
                   @"errorMes": @"FIREBASE Data synchronization exception: not installed FIRAnalytics SDK"
 
            },
        };
    });
    
    return _ta_ThridInfo[typee];
    
}


@end
