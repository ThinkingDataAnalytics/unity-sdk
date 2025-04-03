//
//  NSObject+TDCore.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (TDCore)

- (nullable instancetype)td_filterNull;
- (nullable NSString *)td_string;
- (nullable NSNumber *)td_number;

@end

NS_ASSUME_NONNULL_END
