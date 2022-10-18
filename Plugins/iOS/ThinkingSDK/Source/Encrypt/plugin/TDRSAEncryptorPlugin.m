//
//  TDRSAEncryptorPlugin.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDRSAEncryptorPlugin.h"
#import "TDAESEncryptor.h"
#import "TDRSAEncryptor.h"

@interface TDRSAEncryptorPlugin ()

@property (nonatomic, strong) TDAESEncryptor *aesEncryptor;
@property (nonatomic, strong) TDRSAEncryptor *rsaEncryptor;

@end

@implementation TDRSAEncryptorPlugin

- (instancetype)init {
    self = [super init];
    if (self) {
        _aesEncryptor = [[TDAESEncryptor alloc] init];
        _rsaEncryptor = [[TDRSAEncryptor alloc] init];
    }
    return self;
}


/// 对称加密的类型，例如 AES
- (NSString *)symmetricEncryptType {
    return [_aesEncryptor algorithm];
}

/// 非对称加密的类型，例如 RSA
- (NSString *)asymmetricEncryptType {
    return [_rsaEncryptor algorithm];
}

/// 加密数据
- (NSString *)encryptEvent:(NSData *)event {
    return [_aesEncryptor encryptData:event];
}

/// 加密对称密钥
- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey {
    if (![_rsaEncryptor.key isEqualToString:publicKey]) {
        _rsaEncryptor.key = publicKey;
    }
    return [_rsaEncryptor encryptData:_aesEncryptor.key];
}

@end
