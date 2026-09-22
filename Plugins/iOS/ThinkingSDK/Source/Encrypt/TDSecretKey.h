//
//  TDSecretKey.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDSecretKey : NSObject<NSCopying>

/// Initialize key information
- (instancetype)initWithVersion:(NSUInteger)version publicKey:(NSString *)publicKey;

/// Initialize key information
/// @param version key version number
/// @param publicKey public key
/// @param asymmetricEncryption asymmetric encryption type
/// @param symmetricEncryption Symmetric encryption type
- (instancetype)initWithVersion:(NSUInteger)version
                      publicKey:(NSString *)publicKey
           asymmetricEncryption:(NSString *)asymmetricEncryption
            symmetricEncryption:(NSString *)symmetricEncryption;

@property (nonatomic, assign, readonly) NSUInteger version;
@property (nonatomic, copy, readonly) NSString *publicKey;
@property (nonatomic, copy, readonly) NSString *symmetricEncryption;
@property (nonatomic, copy, readonly) NSString *asymmetricEncryption;

/// Whether the key information is available
@property (nonatomic, assign, readonly) BOOL isValid;

@end

NS_ASSUME_NONNULL_END
