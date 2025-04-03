//
//  NSString+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/12.
//

#import "NSString+TDCore.h"
#import "TDJSONUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (TDCore)

+ (BOOL)td_isEmpty:(NSString *)str {
    if (str == nil) {
        return YES;
    } else {
        if ([str isKindOfClass:NSString.class]) {
            return str.length <= 0;
        } else {
            return YES;
        }
    }
}

- (id)td_jsonObject {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [TDJSONUtil jsonForData:jsonData];
}

- (NSString *)td_trim {
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string;
}

+ (NSString *)td_jsonStringWithJsonObject:(id)jsonObj {
    if ([jsonObj isKindOfClass:NSArray.class] || [jsonObj isKindOfClass:NSDictionary.class]) {
        @try {
            NSError *jsonSeralizeError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObj options:NSJSONWritingPrettyPrinted error:&jsonSeralizeError];
            if (jsonSeralizeError == nil && jsonData != nil) {
                NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                return str;
            }
        } @catch (NSException *exception) {
            return nil;
        }
    }
    return nil;
}

+ (BOOL)td_isEqualWithString1:(NSString *)string1 string2:(NSString *)string2 {
    if (string1 == nil && string2 == nil) {
        return YES;
    } else if ([string1 isEqualToString:string2]) {
        return YES;
    }
    return NO;
}

- (NSString *)td_sha256AndBase64 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSData *output = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    return [output base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

@end
