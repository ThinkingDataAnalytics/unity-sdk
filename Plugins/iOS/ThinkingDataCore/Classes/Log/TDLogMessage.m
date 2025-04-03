//
//  TDLogMessage.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/22.
//

#import "TDLogMessage.h"

@implementation TDLogMessage

- (TDLogMessage *)initWithMessage:(NSString *)message prefix:(NSString *)prefix type:(TDLogType)type {
    if (self = [super init]) {
        self.prefix = prefix;
        self.message = message;
        self.type = type;
    }
    return self;
}

@end
