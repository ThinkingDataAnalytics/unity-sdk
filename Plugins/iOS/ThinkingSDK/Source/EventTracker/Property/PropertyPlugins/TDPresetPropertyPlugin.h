//
//  TAPresetPropertyPlugin.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
#import "TDPropertyPluginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDPresetPropertyPlugin : NSObject<TDPropertyPluginProtocol>

@property(nonatomic, copy)NSString *instanceToken;

@end

NS_ASSUME_NONNULL_END
