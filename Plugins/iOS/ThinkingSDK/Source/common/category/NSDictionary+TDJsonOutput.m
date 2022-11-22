//
//  NSDictionary+TDJsonOutput.m
//  ThinkingSDK
//
//  Created by huangdiao on 2021/3/18.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import "NSDictionary+TDJsonOutput.h"

@implementation NSDictionary (TDJsonOutput)

- (NSString *)descriptionWithLocale:(nullable id)locale {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSString *output = nil;
        @try {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
            output = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            output = [output stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        }
        @catch (NSException *exception) {
            output = self.description;
        }
        return  output;
    } else {
        return self.description;
    }
}

@end
