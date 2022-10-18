//
//  TDAESEncryptor.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDAESEncryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import "TDLogging.h"

@interface TDAESEncryptor ()

@property (nonatomic, copy, readwrite) NSData *key;

@end

@implementation TDAESEncryptor


- (NSData *)key {
    if (!_key) {
        NSUInteger length = 16;
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
        for (NSUInteger i = 0; i < length; i++) {
            [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((uint32_t)[letters length])]];
        }
        _key = [randomString dataUsingEncoding:NSUTF8StringEncoding];
    }
    return _key;
}


- (NSString *)algorithm {
    return @"AES";
}


- (nullable NSString *)encryptData:(NSData *)obj {
    if (!obj) {
        return nil;
    }

    if (!self.key) {
        return nil;
    }
    
    NSData *data = obj;
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [self.key bytes],
                                          kCCBlockSizeAES128,
                                          nil,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {

        NSData *encryptData = [NSData dataWithBytes:buffer length:numBytesEncrypted];
        NSMutableData *ivEncryptData = [NSMutableData data];
        [ivEncryptData appendData:encryptData];
        
        free(buffer);
        
        NSData *base64EncodeData = [ivEncryptData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
        NSString *encryptString = [[NSString alloc] initWithData:base64EncodeData encoding:NSUTF8StringEncoding];
        return encryptString;
    } else {
        free(buffer);
    }
    return nil;
}



@end
