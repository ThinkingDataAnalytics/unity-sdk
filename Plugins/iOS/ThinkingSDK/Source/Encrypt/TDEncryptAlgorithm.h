//
//  TDEncryptAlgorithm.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.


NS_ASSUME_NONNULL_BEGIN

@protocol TDEncryptAlgorithm <NSObject>


- (nullable NSString *)encryptData:(NSData *)data;


- (NSString *)algorithm;

@end

NS_ASSUME_NONNULL_END
