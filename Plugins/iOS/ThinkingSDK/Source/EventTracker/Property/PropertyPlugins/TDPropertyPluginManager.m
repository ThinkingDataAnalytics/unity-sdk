//
//  TDPropertyPluginManager.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDPropertyPluginManager.h"

@interface TDPropertyPluginManager ()
@property (nonatomic, strong) NSMutableArray<id<TDPropertyPluginProtocol>> *plugins;

@end


@implementation TDPropertyPluginManager

//MARK: - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        self.plugins = [NSMutableArray array];
    }
    return self;
}

- (void)registerPropertyPlugin:(id<TDPropertyPluginProtocol>)plugin {
    BOOL isResponds = [plugin respondsToSelector:@selector(properties)];
    NSAssert(isResponds, @"properties plugin must implement `- properties` method!");
    if (!isResponds) {
        return;
    }

    // delete old plugin
    for (id<TDPropertyPluginProtocol> object in self.plugins) {
        if (object.class == plugin.class) {
            [self.plugins removeObject:object];
            break;
        }
    }
    [self.plugins addObject:plugin];

    
    if ([plugin respondsToSelector:@selector(start)]) {
        [plugin start];
    }
}

- (NSMutableDictionary<NSString *,id> *)currentPropertiesForPluginClasses:(NSArray<Class> *)classes {
    NSArray *plugins = [self.plugins copy];
    NSMutableArray<id<TDPropertyPluginProtocol>> *matchResult = [NSMutableArray array];

    for (id<TDPropertyPluginProtocol> obj in plugins) {
        
        for (Class cla in classes) {
            if ([obj isKindOfClass:cla]) {
                [matchResult addObject:obj];
                break;
            }
        }
    }
    
    NSMutableDictionary *pluginProperties = [self propertiesWithPlugins:matchResult];

    return pluginProperties;
}

- (NSMutableDictionary<NSString *,id> *)propertiesWithEventType:(TDEventType)type {
    
    NSArray *plugins = [self.plugins copy];
    NSMutableArray<id<TDPropertyPluginProtocol>> *matchResult = [NSMutableArray array];
    for (id<TDPropertyPluginProtocol> obj in plugins) {
        if ([self isMatchedWithPlugin:obj eventType:type]) {
            [matchResult addObject:obj];
        }
    }
    return [self propertiesWithPlugins:matchResult];
}

//MARK: - Private Methods

- (NSMutableDictionary *)propertiesWithPlugins:(NSArray<id<TDPropertyPluginProtocol>> *)plugins {
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    for (id<TDPropertyPluginProtocol> plugin in plugins) {
        if ([plugin respondsToSelector:@selector(start)]) {
            [plugin start];
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        if ([plugin respondsToSelector:@selector(asyncGetPropertyCompletion:)]) {
            [plugin asyncGetPropertyCompletion:^(NSDictionary<NSString *,id> * _Nonnull dict) {
                [properties addEntriesFromDictionary:dict];
                dispatch_semaphore_signal(semaphore);
            }];
        }
        
        NSDictionary *pluginProperties = [plugin respondsToSelector:@selector(properties)] ? plugin.properties : nil;
        if (pluginProperties) {
            [properties addEntriesFromDictionary:pluginProperties];
        }
        if (semaphore) {
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)));
        }
    
    }
    return properties;
}

- (BOOL)isMatchedWithPlugin:(id<TDPropertyPluginProtocol>)plugin eventType:(TDEventType)type {
    TDEventType eventTypeFilter;

    if (![plugin respondsToSelector:@selector(eventTypeFilter)]) {
        // If the plug-in does not implement the type filtering method, it will only be added for track type data by default, including the first event, updateable event, and rewritable event. In addition to user attribute events
        eventTypeFilter = TDEventTypeTrack | TDEventTypeTrackFirst | TDEventTypeTrackUpdate | TDEventTypeTrackOverwrite;
    } else {
        eventTypeFilter = plugin.eventTypeFilter;
    }
    
    if ((eventTypeFilter & type) == type) {
        return YES;
    }
    return NO;
}

@end
