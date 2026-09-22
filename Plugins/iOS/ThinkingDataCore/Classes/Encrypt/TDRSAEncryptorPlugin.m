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
    NSData *encryptData = [_aesEncryptor encryptData:event];
    NSString *result = [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return result;
}

- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey {
    if (![_rsaEncryptor.key isEqualToString:publicKey]) {
        _rsaEncryptor.key = publicKey;
    }
    NSData *aesKeyData = [self.aesEncryptor.key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptData = [_rsaEncryptor encryptData:aesKeyData];
    NSString *result = [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return result;
}

@end
