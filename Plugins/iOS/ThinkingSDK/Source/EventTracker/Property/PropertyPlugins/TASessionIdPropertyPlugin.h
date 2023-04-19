//
//  TASessionIdPropertyPlugin.h
//  ThinkingSDK
//
//  Created by Charles on 28.11.22.
//

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif
#import "TAPropertyPluginManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TASessionIdPropertyPlugin : NSObject<TAPropertyPluginProtocol>

@property(nonatomic, copy)NSString *instanceToken;

- (void)updateSessionId;

@end

NS_ASSUME_NONNULL_END
