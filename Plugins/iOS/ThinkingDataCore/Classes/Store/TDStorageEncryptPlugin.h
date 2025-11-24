//
//  TDStorageEncryptPlugin.h
//  ThinkingDataCore
//
//  Created by 廖德生 on 2024/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TDStorageEncryptStringPrefix;

@interface TDStorageEncryptPlugin : NSObject

+ (instancetype)sharedInstance;
- (void)enableEncrypt;
- (BOOL)isEnableEncrypt;

- (id)encryptDataIfNeed:(id)data;
- (id)decryptDataIfNeed:(id)data;

/// When the encryption is successful, the return value is the path of the encrypted file. If encryption fails or is disabled, the returned value is null
- (nullable NSString *)encryptFileAtPathIfNeed:(NSString *)filePath;
- (NSData *)decryptFileAtPath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
