//
//  TDPropertyPluginManager.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import <Foundation/Foundation.h>
#import "TDBaseEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TDPropertyPluginCompletion)(NSDictionary<NSString *, id> *properties);

@protocol TDPropertyPluginProtocol <NSObject>

@property(nonatomic, copy)NSString *instanceToken;

- (NSDictionary<NSString *, id> *)properties;

@optional

- (void)start;

- (TDEventType)eventTypeFilter;

- (void)asyncGetPropertyCompletion:(TDPropertyPluginCompletion)completion;

@end


@interface TDPropertyPluginManager : NSObject

- (void)registerPropertyPlugin:(id<TDPropertyPluginProtocol>)plugin;

- (NSMutableDictionary<NSString *, id> *)currentPropertiesForPluginClasses:(NSArray<Class> *)classes;

- (NSMutableDictionary<NSString *, id> *)propertiesWithEventType:(TDEventType)type;

@end

NS_ASSUME_NONNULL_END
