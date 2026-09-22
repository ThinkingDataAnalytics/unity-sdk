//
//  TDEncryptAlgorithm.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.


NS_ASSUME_NONNULL_BEGIN

@protocol TDEncryptAlgorithm <NSObject>

/// encrypt data
- (nullable NSData *)encryptData:(NSData *)data;

/// decrypt data. Only implement in AES
- (nullable NSData *)decryptData:(NSData *)data;

/// Name of the encryption algorithm
- (NSString *)algorithm;

@end

NS_ASSUME_NONNULL_END
