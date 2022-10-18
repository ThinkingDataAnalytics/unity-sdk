//
//  TDSecretKey.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDSecretKey : NSObject<NSCopying>

/// 初始化密钥信息
/// @param version 密钥版本号
/// @param publicKey 公钥
///  默认采用RSA+AES加密方式
- (instancetype)initWithVersion:(NSUInteger)version publicKey:(NSString *)publicKey;

/// 初始化密钥信息
/// @param version 密钥版本号
/// @param publicKey 公钥
/// @param asymmetricEncryption 非对称加密类型
/// @param symmetricEncryption 对称加密类型
- (instancetype)initWithVersion:(NSUInteger)version
                      publicKey:(NSString *)publicKey
           asymmetricEncryption:(NSString *)asymmetricEncryption
            symmetricEncryption:(NSString *)symmetricEncryption;

@property (nonatomic, assign, readonly) NSUInteger version;
@property (nonatomic, copy, readonly) NSString *publicKey;
@property (nonatomic, copy, readonly) NSString *symmetricEncryption;
@property (nonatomic, copy, readonly) NSString *asymmetricEncryption;

/// 该密钥信息是否可用
@property (nonatomic, assign, readonly) BOOL isValid;

@end

NS_ASSUME_NONNULL_END
