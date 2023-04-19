//
//  NSString+TDString.h
//  ThinkingSDK
//
//  Created by wwango on 2021/10/11.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TDString)

- (NSString *)td_trim;

- (NSString * _Nullable)ta_formatUrlString;

@end

NS_ASSUME_NONNULL_END
