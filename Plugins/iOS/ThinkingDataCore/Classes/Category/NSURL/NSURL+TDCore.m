//
//  NSURL+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/5/27.
//

#import "NSURL+TDCore.h"

@implementation NSURL (TDCore)

+ (NSString *)td_baseUrlStringWithString:(NSString *)urlString {
    NSString *formatString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:formatString];
    NSString *scheme = [url scheme];
    NSString *host = [url host];
    NSNumber *port = [url port];
    
    if (scheme && scheme.length > 0 && host && host.length > 0) {
        formatString = [NSString stringWithFormat:@"%@://%@", scheme, host];
        if (port && [port stringValue]) {
            formatString = [formatString stringByAppendingFormat:@":%@", [port stringValue]];
        }
    }
    return formatString;
}


@end
