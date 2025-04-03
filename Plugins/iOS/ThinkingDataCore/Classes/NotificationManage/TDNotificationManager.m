//
//  TDNotificationManager.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/12.
//

#import "TDNotificationManager.h"

@implementation TDNotificationManager

+ (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

@end
