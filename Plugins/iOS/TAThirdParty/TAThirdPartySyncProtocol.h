//
//  TAThirdPartySyncProtocol.h
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/2/17.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAThinkingTrackProtocol <NSObject>

- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;
- (NSString *)getDistinctId;
- (NSString *)getAccountId;

@end


@protocol TAThirdPartySyncProtocol <NSObject>

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance;
- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property;

@end

@protocol TAThirdPartyProtocol <NSObject>

- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance;
- (void)enableThirdPartySharing:(NSNumber *)type instance:(id<TAThinkingTrackProtocol>)instance property:(NSDictionary *)property;

@end

NS_ASSUME_NONNULL_END
