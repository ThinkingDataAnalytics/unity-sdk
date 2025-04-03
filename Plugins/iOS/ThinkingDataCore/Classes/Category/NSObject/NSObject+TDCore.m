//
//  NSObject+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/13.
//

#import "NSObject+TDCore.h"

@implementation NSObject (TDCore)

- (instancetype)td_filterNull {
    if ([self isKindOfClass:NSNull.class]) {
        return nil;
    }
    return self;
}

- (NSString *)td_string {
    NSObject *target = [self td_filterNull];
    if ([target isKindOfClass:NSString.class]) {
        return (NSString *)target;
    }
    if ([target isKindOfClass:NSNumber.class]) {
        return [NSString stringWithFormat:@"%@", target];
    }
    return nil;
}

- (NSNumber *)td_number {
    NSObject *target = [self td_filterNull];
    if ([target isKindOfClass:NSString.class]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *number = [formatter numberFromString:(NSString *)target];
        return number;
    }
    if ([target isKindOfClass:NSNumber.class]) {
        return (NSNumber *)target;
    }
    return nil;
}


@end
