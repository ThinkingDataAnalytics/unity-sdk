//
//  TDEncryptProtocol.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.
//  加密插件遵守的协议

NS_ASSUME_NONNULL_BEGIN

@protocol TDEncryptProtocol <NSObject>

/// 对称加密的类型
- (NSString *)symmetricEncryptType;

/// 非对称加密的类型
- (NSString *)asymmetricEncryptType;

/// 加密数据
- (NSString *)encryptEvent:(NSData *)event;

/// 使用公钥加密对称密钥
- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
