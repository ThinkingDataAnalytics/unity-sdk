//
//  TDPresetProperties.m
//  ThinkingSDK
//
//  Created by huangdiao on 2021/5/25.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "TDPresetProperties.h"
#import "TDPresetProperties+TDDisProperties.h"

@interface TDPresetProperties ()

@property (nonatomic, copy, readwrite) NSString *bundle_id;
@property (nonatomic, copy, readwrite) NSString *carrier;
@property (nonatomic, copy, readwrite) NSString *device_id;
@property (nonatomic, copy, readwrite) NSString *device_model;
@property (nonatomic, copy, readwrite) NSString *manufacturer;
@property (nonatomic, copy, readwrite) NSString *network_type;
@property (nonatomic, copy, readwrite) NSString *os;
@property (nonatomic, copy, readwrite) NSString *os_version;
@property (nonatomic, copy, readwrite) NSNumber *screen_height;
@property (nonatomic, copy, readwrite) NSNumber *screen_width;
@property (nonatomic, copy, readwrite) NSString *system_language;
@property (nonatomic, copy, readwrite) NSNumber *zone_offset;

@property (nonatomic, copy) NSDictionary *presetProperties;

@end

@implementation TDPresetProperties

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateValuesWithDictionary:dict];
    }
    return self;
}



- (void)updateValuesWithDictionary:(NSDictionary *)dict {
    _bundle_id = dict[@"#bundle_id"]?:@"";
    _carrier = dict[@"#carrier"]?:@"";
    _device_id = dict[@"#device_id"]?:@"";
    _device_model = dict[@"#device_model"]?:@"";
    _manufacturer = dict[@"#manufacturer"]?:@"";
    _network_type = dict[@"#network_type"]?:@"";
    _os = dict[@"#os"]?:@"";
    _os_version = dict[@"#os_version"]?:@"";
    _screen_height = dict[@"#screen_height"]?:@(0);
    _screen_width = dict[@"#screen_width"]?:@(0);
    _system_language = dict[@"#system_language"]?:@"";
    _zone_offset = dict[@"#zone_offset"]?:@(0);

    _presetProperties = [NSDictionary dictionaryWithDictionary:dict];
    
    // 过滤不需要的预置属性
    NSMutableDictionary *updateProperties = [_presetProperties mutableCopy];
    NSArray *propertykeys = updateProperties.allKeys;
    NSArray *registerkeys = [TDPresetProperties disPresetProperties];
    NSMutableSet *set1 = [NSMutableSet setWithArray:propertykeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:registerkeys];
    [set1 intersectSet:set2];// 求交集
    if (set1.allObjects.count) {
        [updateProperties removeObjectsForKeys:set1.allObjects];
    }
    
    _presetProperties = updateProperties;
}

- (NSDictionary *)toEventPresetProperties {
    return [_presetProperties copy];
}

@end
