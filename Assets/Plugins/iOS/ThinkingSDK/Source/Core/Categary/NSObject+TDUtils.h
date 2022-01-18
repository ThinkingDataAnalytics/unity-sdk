//
//  NSObject+TDUtils.h
//  ThinkingSDK
//
//  Created by wwango on 2021/10/18.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDUtils)

+ (id)performSelector:(SEL)selector onTarget:(id)target withArguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
