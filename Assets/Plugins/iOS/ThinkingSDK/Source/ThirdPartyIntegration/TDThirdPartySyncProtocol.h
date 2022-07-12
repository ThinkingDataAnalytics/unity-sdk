//
//  TDThirdPartySyncProtocol.h
//  ThinkingSDKDEMO
//
//  Created by wwango on 2022/2/17.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TDThinkingTrackProtocol <NSObject>

- (void)track:(NSString *)event properties:(nullable NSDictionary *)propertieDict;
- (NSString *)getDistinctId;
- (NSString *)getAccountId;

@end


@protocol TDThirdPartySyncProtocol <NSObject>

- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance;
- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance property:(NSDictionary *)property;

@end

NS_ASSUME_NONNULL_END
