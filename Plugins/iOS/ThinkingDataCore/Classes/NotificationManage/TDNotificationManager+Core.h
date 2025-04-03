//
//  TDNotificationManager+Core.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/6/27.
//

#if __has_include(<ThinkingDataCore/TDNotificationManager.h>)
#import <ThinkingDataCore/TDNotificationManager.h>
#else
#import "TDNotificationManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kCoreNotificationNameCalibratedTimeSuccess;
extern NSString * const kCoreNotificationParamsCalibratedTimeNow;

@interface TDNotificationManager (Core)

+ (void)postCoreNotificationCalibratedTimeSuccess:(NSDate *)now;

@end

NS_ASSUME_NONNULL_END
