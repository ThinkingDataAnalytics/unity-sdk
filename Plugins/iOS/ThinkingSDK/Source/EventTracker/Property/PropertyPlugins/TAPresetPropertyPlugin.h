//
//  TAPresetPropertyPlugin.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
#import "TAPropertyPluginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPresetPropertyPlugin : NSObject<TAPropertyPluginProtocol>

@property(nonatomic, copy)NSString *instanceToken;

@property (nonatomic, strong) NSTimeZone *defaultTimeZone;

@end

NS_ASSUME_NONNULL_END
