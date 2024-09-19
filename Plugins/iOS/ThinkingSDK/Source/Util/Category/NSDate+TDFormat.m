//
//  NSDate+TDFormat.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "NSDate+TDFormat.h"

@implementation NSDate (TDFormat)

- (double)ta_timeZoneOffset:(NSTimeZone *)timeZone {
    if (!timeZone) {
        return 0;
    }
    NSInteger sourceGMTOffset = [timeZone secondsFromGMTForDate:self];
    return (double)(sourceGMTOffset/3600.0);
}

- (NSString *)ta_formatWithTimeZone:(NSTimeZone *)timeZone formatString:(NSString *)formatString {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = formatString;
    timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    timeFormatter.timeZone = timeZone;
    return [timeFormatter stringFromDate:self];
}

@end
