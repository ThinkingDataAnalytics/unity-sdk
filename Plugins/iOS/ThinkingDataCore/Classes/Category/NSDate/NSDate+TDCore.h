//
//  NSDate+TDCore.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TDCore)

+ (nullable NSDate *)td_dateWithString:(nonnull NSString *)dateString formatter:(nullable NSString *)formatter timeZone:(nullable NSTimeZone *)timeZone;

- (double)td_timeZoneOffset:(NSTimeZone *)timeZone;

- (NSString *)td_formatWithTimeZone:(NSTimeZone *)timeZone formatString:(NSString *)formatString;

@end

NS_ASSUME_NONNULL_END
