//
//  NSString+TDString.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/11.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "NSString+TDString.h"
#import "TDLogging.h"

@implementation NSString (TDString)

- (NSString *)td_trim {
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string;
}

@end
