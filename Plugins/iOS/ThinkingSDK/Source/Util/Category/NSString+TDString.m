//
//  NSString+TDString.m
//  ThinkingSDK
//
//  Created by wwango on 2021/10/11.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "NSString+TDString.h"

@implementation NSString (TDString)

- (NSString *)td_trim {
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string;
}

- (NSString *)ta_formatUrlString {
    NSString *urlString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSNumber *port = [url port];
    
    if (scheme && scheme.length>0 && host && host.length>0) {
        urlString = [NSString stringWithFormat:@"%@://%@", scheme, host];
        if (port && [port stringValue]) {
            urlString = [urlString stringByAppendingFormat:@":%@", [port stringValue]];
        }
    }
    return urlString;
}

@end
