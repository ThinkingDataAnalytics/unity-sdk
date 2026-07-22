#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCalibratedTime : NSObject
@property (atomic, assign, readonly) BOOL hasBeenCalibrated;

+ (instancetype)sharedInstance;

+ (NSDate *)now;

- (void)recalibrationWithTimeInterval:(NSTimeInterval)timestamp;
- (void)recalibrationWithNtps:(NSArray *)ntpServers;

@end

NS_ASSUME_NONNULL_END
