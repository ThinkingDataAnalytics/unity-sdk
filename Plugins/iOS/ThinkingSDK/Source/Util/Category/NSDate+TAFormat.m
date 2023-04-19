//
//  NSDate+TAFormat.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "NSDate+TAFormat.h"

@implementation NSDate (TAFormat)

- (double)ta_timeZoneOffset:(NSTimeZone *)timeZone {
    if (!timeZone) {
        return 0;
    }
    NSInteger sourceGMTOffset = [timeZone secondsFromGMTForDate:self];
    return (double)(sourceGMTOffset/3600);
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
