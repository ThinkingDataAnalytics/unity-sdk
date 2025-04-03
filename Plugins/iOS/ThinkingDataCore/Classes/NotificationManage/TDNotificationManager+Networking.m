//
//  TDNotificationManager+Networking.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/15.
//

#import "TDNotificationManager+Networking.h"

NSString * const kNetworkNotificationNameStatusChange = @"kNetworkNotificationNameStatusChange";
NSString * const kNetworkNotificationParamsNetworkType = @"network";

@implementation TDNotificationManager (Networking)

+ (void)postNetworkStatusChanged:(NSString *)networkStatus {
    if (networkStatus.length == 0) {
        return;
    }
    [self postNotificationName:kNetworkNotificationNameStatusChange object:nil userInfo:@{
        kNetworkNotificationParamsNetworkType: networkStatus
    }];
}

@end
