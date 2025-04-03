//
//  NSString+TDCore.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/3/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TDCore)

+ (BOOL)td_isEmpty:(NSString *)str;

- (nullable id)td_jsonObject;

- (NSString *)td_trim;

+ (nullable NSString *)td_jsonStringWithJsonObject:(id)jsonObj;

+ (BOOL)td_isEqualWithString1:(nullable NSString *)string1 string2:(nullable NSString *)string2;

- (NSString *)td_sha256AndBase64;

@end

NS_ASSUME_NONNULL_END
