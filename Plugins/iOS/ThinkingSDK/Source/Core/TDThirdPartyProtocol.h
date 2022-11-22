//
//  TDThirdPartyProtocol.h
//  Pods
//
//  Created by wwango on 2022/2/17.
//

@protocol TDThirdPartyProtocol <NSObject>

- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id)instance;
- (void)enableThirdPartySharing:(TAThirdPartyShareType)type instance:(id)instance property:(NSDictionary *)property;

@end
