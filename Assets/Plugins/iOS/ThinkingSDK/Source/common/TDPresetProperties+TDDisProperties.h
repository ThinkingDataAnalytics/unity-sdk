//
//  TDPresetProperties+TDDisProperties.h
//  ThinkingSDK
//
//  Created by wwango on 2021/12/7.
//  不能使用的

#import "TDPresetProperties.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDPresetProperties (TDDisProperties)

@property(class, nonatomic, readonly) BOOL disableStartReason;
@property(class, nonatomic, readonly) BOOL disableDisk;
@property(class, nonatomic, readonly) BOOL disableRAM;
@property(class, nonatomic, readonly) BOOL disableFPS;
@property(class, nonatomic, readonly) BOOL disableSimulator;

/// 需要过滤的预置属性
+ (NSArray*)disPresetProperties;

/// 过滤预置属性
/// @param dataDic 外层property
+ (void)handleFilterDisPresetProperties:(NSMutableDictionary *)dataDic;

@end

NS_ASSUME_NONNULL_END
