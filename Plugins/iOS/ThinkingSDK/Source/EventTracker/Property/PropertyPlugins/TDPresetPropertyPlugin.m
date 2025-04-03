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

@end

@implementation TDPresetPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    NSDictionary *staticProperties = [TDCorePresetProperty staticProperties];
    [self.properties addEntriesFromDictionary:staticProperties];
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
