//
//  NSNumber+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/7/24.
//

#import "NSNumber+TDCore.h"

@implementation NSNumber (TDCore)

- (BOOL)td_isBool {
    const char *type = [self objCType];
    if (strcmp(type, "c") == 0 && ([self isEqualToNumber:@YES] || [self isEqualToNumber:@NO])) {
        return YES;
    }
    return NO;
}

@end
