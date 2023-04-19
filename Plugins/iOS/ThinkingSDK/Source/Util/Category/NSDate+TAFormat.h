//
//  NSDate+TAFormat.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (TAFormat)

/// input the time zone
/// @param timeZone timeZone
- (double)ta_timeZoneOffset:(NSTimeZone *)timeZone;

/// Format NSDate
/// @param timeZone timeZone
/// @param formatString formatString
- (NSString *)ta_formatWithTimeZone:(NSTimeZone *)timeZone formatString:(NSString *)formatString;

@end

NS_ASSUME_NONNULL_END
