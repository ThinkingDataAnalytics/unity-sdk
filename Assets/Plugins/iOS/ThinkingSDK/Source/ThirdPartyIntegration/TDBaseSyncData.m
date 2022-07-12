//
//  TDBaseSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/14.
//

#import "TDBaseSyncData.h"

@implementation TDBaseSyncData

- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    self.taInstance = taInstance;
    self.customPropety = property;
}

- (void)syncThirdData:(id<TDThinkingTrackProtocol>)taInstance {
    [self syncThirdData:taInstance property:@{}];
}

@end
