//
//  TDThirdPartyManager.h
//  ThinkingSDK
//
//  Created by wwango on 2022/2/11.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"
#import "TDThirdPartySyncProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDThirdPartyManager : NSObject

- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance;
- (void)enableThirdPartySharing:(TDThirdPartyShareType)type instance:(id<TDThinkingTrackProtocol>)instance property:(NSDictionary *)property;

@end

NS_ASSUME_NONNULL_END
