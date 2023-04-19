#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDCalibratedTime.h>)
#import <ThinkingSDK/TDCalibratedTime.h>
#else
#import "TDCalibratedTime.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDCalibratedTimeWithNTP : TDCalibratedTime

- (void)recalibrationWithNtps:(NSArray *)ntpServers;

@end

NS_ASSUME_NONNULL_END
