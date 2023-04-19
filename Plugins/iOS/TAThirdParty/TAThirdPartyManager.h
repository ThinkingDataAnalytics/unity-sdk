//
//  TAThirdPartyManager.h
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import "TAThirdPartySyncProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAThirdPartyManager : NSObject<TAThirdPartyProtocol>

- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance;
- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property;

@end

NS_ASSUME_NONNULL_END
