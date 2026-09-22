//
//  TAPresetPropertyPlugin.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDPresetPropertyPlugin.h"
#import "TDAnalyticsPresetProperty.h"

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetProperty.h>)
#import <ThinkingDataCore/TDCorePresetProperty.h>
#else
#import "TDCorePresetProperty.h"
#endif

@interface TDPresetPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;
@property (nonatomic, strong) id lockObject;
@end

@implementation TDPresetPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        _properties = [NSMutableDictionary dictionary];
        self.lockObject = [[NSObject alloc] init];
    }
    return self;
}

- (void)start {
    @synchronized(self.lockObject) {
        NSDictionary *staticProperties = [TDCorePresetProperty staticProperties];
        [_properties addEntriesFromDictionary:staticProperties];
    }
}

- (NSDictionary *)properties {
    @synchronized(self.lockObject) {
        return [_properties copy];
    }
}

/// The properties here are dynamically updated
///
- (void)asyncGetPropertyCompletion:(TDPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    NSDictionary *dynamicProperties = [TDCorePresetProperty dynamicProperties];
    [mutableDict addEntriesFromDictionary:dynamicProperties];
    
    NSDictionary *analyticsProperties = [TDAnalyticsPresetProperty propertiesWithAppId:self.instanceToken];
    [mutableDict addEntriesFromDictionary:analyticsProperties];
    
    if (completion) {
        completion(mutableDict);
    }
}

@end
