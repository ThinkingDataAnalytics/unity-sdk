//
//  TDAESEncryptor.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDAESEncryptor.h"
#import <CommonCrypto/CommonCryptor.h>

@interface TDAESEncryptor ()

@end

@implementation TDAESEncryptor

- (NSString *)randomKey {
    NSUInteger length = 16;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

- (NSString *)key {
    if (_key == nil) {
        _key = [self randomKey];
    }
    return _key;
}

- (NSString *)algorithm {
    return @"AES";
}

- (NSData *)encryptData:(NSData *)data {
    if (!data) {
        return nil;
    }

    if (!self.key) {
        return nil;
    }
    
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    NSData *keyData = [self.key dataUsingEncoding:NSUTF8StringEncoding];
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [keyData bytes],
                                          kCCBlockSizeAES128,
                                          nil,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    NSData *result = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
        NSMutableData *ivEncryptData = [NSMutableData data];
        [ivEncryptData appendData:encryptData];
        result = ivEncryptData;
    }
    free(buffer);
    return result;
}

- (NSData *)decryptData:(NSData *)data {
    if (!data) {
        return nil;
    }

    if (!self.key) {
        return nil;
    }
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    NSData *keyData = [self.key dataUsingEncoding:NSUTF8StringEncoding];

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyData.bytes,
                                          kCCKeySizeAES128,
                                          nil,
                                          data.bytes,
                                          data.length,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    NSData *decryptData = nil;
    if (cryptStatus == kCCSuccess) {
        decryptData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return decryptData;
}

@end
