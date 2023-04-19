//
//  TABaseSyncData.m
//  ThinkingSDK
//
//  Created by wwango on 2022/2/14.
//

#import "TABaseSyncData.h"

@implementation TABaseSyncData

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance property:(NSDictionary *)property {
    self.taInstance = taInstance;
    self.customPropety = property;
}

- (void)syncThirdData:(id<TAThinkingTrackProtocol>)taInstance {
    [self syncThirdData:taInstance property:@{}];
}

@end
