//
//  TAPropertyPluginManager.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import <Foundation/Foundation.h>
#import "TABaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TAPropertyPluginCompletion)(NSDictionary<NSString *, id> *properties);

@protocol TAPropertyPluginProtocol <NSObject>

@property(nonatomic, copy)NSString *instanceToken;

- (NSDictionary<NSString *, id> *)properties;

@optional

- (void)start;

- (TAEventType)eventTypeFilter;

- (void)asyncGetPropertyCompletion:(TAPropertyPluginCompletion)completion;

@end


@interface TAPropertyPluginManager : NSObject

- (void)registerPropertyPlugin:(id<TAPropertyPluginProtocol>)plugin;

- (NSMutableDictionary<NSString *, id> *)currentPropertiesForPluginClasses:(NSArray<Class> *)classes;

- (NSMutableDictionary<NSString *, id> *)propertiesWithEventType:(TAEventType)type;

@end

NS_ASSUME_NONNULL_END
