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


- (NSString *)symmetricEncryptType {
    return [_aesEncryptor algorithm];
}


- (NSString *)asymmetricEncryptType {
    return [_rsaEncryptor algorithm];
}


- (NSString *)encryptEvent:(NSData *)event {
    return [_aesEncryptor encryptData:event];
}


- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey {
    if (![_rsaEncryptor.key isEqualToString:publicKey]) {
        _rsaEncryptor.key = publicKey;
    }
    return [_rsaEncryptor encryptData:_aesEncryptor.key];
}

@end
