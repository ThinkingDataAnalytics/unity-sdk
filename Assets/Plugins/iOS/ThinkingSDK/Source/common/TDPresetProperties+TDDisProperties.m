//
//  TDPresetProperties+TDDisProperties.m
//  ThinkingSDK
//
//  Created by wwango on 2021/12/7.
//

#import "TDPresetProperties+TDDisProperties.h"

static BOOL _td_disableStartReason;
static BOOL _td_disableDisk;
static BOOL _td_disableRAM;
static BOOL _td_disableFPS;
static BOOL _td_disableSimulator;

static const NSString *kTDStartReason  = @"#start_reason";

static const NSString *kTDPerformanceRAM  = @"#ram";
static const NSString *kTDPerformanceDISK = @"#disk";
static const NSString *kTDPerformanceSIM  = @"#simulator";
static const NSString *kTDPerformanceFPS  = @"#fps";

#define TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY @"TDDisPresetProperties"

@implementation TDPresetProperties (TDDisProperties)

static NSArray *__td_disPresetProperties;

+ (NSArray*)disPresetProperties {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __td_disPresetProperties = (NSArray *)[[[NSBundle mainBundle] infoDictionary] objectForKey:TD_MAIM_INFO_PLIST_DISPRESTPRO_KEY];
        if (__td_disPresetProperties && __td_disPresetProperties.count) {
            _td_disableStartReason = [__td_disPresetProperties containsObject:kTDStartReason];
            _td_disableDisk        = [__td_disPresetProperties containsObject:kTDPerformanceDISK];
            _td_disableRAM         = [__td_disPresetProperties containsObject:kTDPerformanceRAM];
            _td_disableFPS         = [__td_disPresetProperties containsObject:kTDPerformanceFPS];
            _td_disableSimulator   = [__td_disPresetProperties containsObject:kTDPerformanceSIM];
        }
    });
    return __td_disPresetProperties;
}


+ (void)handleFilterDisPresetProperties:(NSMutableDictionary *)dataDic
{
    if (!__td_disPresetProperties || !__td_disPresetProperties.count) {
        return ;
    }
    NSArray *propertykeys = dataDic.allKeys;
    NSArray *registerkeys = [TDPresetProperties disPresetProperties];
    NSMutableSet *set1 = [NSMutableSet setWithArray:propertykeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:registerkeys];
    [set1 intersectSet:set2];// 求交集
    if (!set1.allObjects.count) {
        return ;
    }
    [dataDic removeObjectsForKeys:set1.allObjects];
    return ;
}


+ (BOOL)disableStartReason {
    return _td_disableStartReason;
}

+ (BOOL)disableDisk {
    return _td_disableDisk;
}

+ (BOOL)disableRAM {
    return _td_disableRAM;
}

+ (BOOL)disableFPS {
    return _td_disableFPS;
}

+ (BOOL)disableSimulator {
    return _td_disableSimulator;
}

@end
