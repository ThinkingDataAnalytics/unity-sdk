//
//  NSObject+TDUtil.h
//  ThinkingSDK
//
//  Created by wwango on 2021/10/18.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDUtil)

+ (id)performSelector:(SEL)selector onTarget:(id)target withArguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
