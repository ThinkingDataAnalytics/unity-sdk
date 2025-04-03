//
//  TDNotificationManager+Networking.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/15.
//

#if __has_include(<ThinkingDataCore/TDNotificationManager.h>)
#import <ThinkingDataCore/TDNotificationManager.h>
#else
#import "TDNotificationManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNetworkNotificationNameStatusChange;
extern NSString * const kNetworkNotificationParamsNetworkType;

@interface TDNotificationManager (Networking)

+ (void)postNetworkStatusChanged:(NSString *)networkStatus;

@end

NS_ASSUME_NONNULL_END
