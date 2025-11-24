//
//  NSDictionary+TDCore.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/14.
//

#import "NSDictionary+TDCore.h"

@implementation NSDictionary (TDCore)

- (NSDictionary *)deepCopy {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
