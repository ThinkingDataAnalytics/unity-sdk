//
//  TDEncryptProtocol.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/27.


NS_ASSUME_NONNULL_BEGIN

@protocol TDEncryptProtocol <NSObject>


- (NSString *)symmetricEncryptType;


- (NSString *)asymmetricEncryptType;


- (NSString *)encryptEvent:(NSData *)event;


- (NSString *)encryptSymmetricKeyWithPublicKey:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
