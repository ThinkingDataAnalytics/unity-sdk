//
//  TAThirdPartyManager.h
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"
#import "TAThirdPartySyncProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAThirdPartyManager : NSObject

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id<TAThinkingTrackProtocol>)instance;
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property;

@end

NS_ASSUME_NONNULL_END
