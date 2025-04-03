//
//  NSDate+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/13.
//

#import "NSDate+TDCore.h"
#import "NSString+TDCore.h"

@implementation NSDate (TDCore)

+ (NSDate *)td_dateWithString:(NSString *)dateString formatter:(NSString *)formatter timeZone:(nullable NSTimeZone *)timeZone {
    if ([NSString td_isEmpty:dateString]) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    NSDate *date = nil;
    if (![NSString td_isEmpty:formatter]) {
        [dateFormatter setDateFormat:formatter];
        date = [dateFormatter dateFromString:dateString];
    }
    if (!date) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        date = [dateFormatter dateFromString:dateString];
    }
    if (!date) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        date = [dateFormatter dateFromString:dateString];
    }
    if (!date) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        date = [dateFormatter dateFromString:dateString];
    }
    return date;
}

- (double)td_timeZoneOffset:(NSTimeZone *)timeZone {
    if (!timeZone) {
        return 0;
    }
    NSInteger sourceGMTOffset = [timeZone secondsFromGMTForDate:self];
    return (double)(sourceGMTOffset/3600.0);
}

- (NSString *)td_formatWithTimeZone:(NSTimeZone *)timeZone formatString:(NSString *)formatString {
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = formatString;
    timeFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    timeFormatter.timeZone = timeZone;
    return [timeFormatter stringFromDate:self];
}

@end
