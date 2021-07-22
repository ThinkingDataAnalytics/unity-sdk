#import <Foundation/Foundation.h>

#import "TDCalibratedTime.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDCalibratedTimeWithNTP : TDCalibratedTime

- (void)recalibrationWithNtps:(NSArray *)ntpServers;

@end

NS_ASSUME_NONNULL_END
