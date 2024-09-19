//
//  TDEncryptManager.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDEncryptManager.h"
#import "TDEncryptProtocol.h"
#import "TDSecretKey.h"
#import "TDRSAEncryptorPlugin.h"
#if __has_include(<ThinkingDataCore/NSData+TDGzip.h>)
#import <ThinkingDataCore/NSData+TDGzip.h>
#else
#import "NSData+TDGzip.h"
#endif
#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif
#import "TDLogging.h"

@interface TDEncryptManager ()
@property (nonatomic, strong) id<TDEncryptProtocol> encryptor;
@property (nonatomic, copy) NSArray<id<TDEncryptProtocol>> *encryptors;
@property (nonatomic, copy) NSString *encryptedSymmetricKey;
@property (nonatomic, strong) TDSecretKey *secretKey;
@property (nonatomic, strong) TDSecretKey *customSecretKey;

@end

@implementation TDEncryptManager

- (instancetype)initWithSecretKey:(TDSecretKey *)secretKey {
    self = [self init];
    if (self) {
        self.customSecretKey = secretKey;
        [self updateEncryptor:secretKey];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray *encryptors = [NSMutableArray array];
        [encryptors addObject:[TDRSAEncryptorPlugin new]];
        self.encryptors = encryptors;
    }
    return self;
}

- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig {
    
    if (!encryptConfig || ![encryptConfig isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    if (![encryptConfig objectForKey:@"version"]) {
        return;
    }
    
    NSInteger version = [[encryptConfig objectForKey:@"version"] integerValue];
    TDSecretKey *secretKey = [[TDSecretKey alloc] initWithVersion:version
                                                        publicKey:encryptConfig[@"key"]
                                             asymmetricEncryption:encryptConfig[@"asymmetric"]
                                              symmetricEncryption:encryptConfig[@"symmetric"]];
    
    
    if (![secretKey isValid]) {
        return;
    }
    
    
    if (![self encryptorWithSecretKey:secretKey]) {
        return;
    }
    
    
    [self updateEncryptor:secretKey];
}

- (void)updateEncryptor:(TDSecretKey *)obj {
    @try {

        TDSecretKey *secretKey = obj;
        if (!secretKey.publicKey.length) {
            return;
        }

        if ([self needUpdateSecretKey:self.secretKey newSecretKey:secretKey]) {
            return;
        }

        id<TDEncryptProtocol> encryptor = [self filterEncrptor:secretKey];
        if (!encryptor) {
            return;
        }

        NSString *encryptedSymmetricKey = [encryptor encryptSymmetricKeyWithPublicKey:secretKey.publicKey];
        
        if (encryptedSymmetricKey.length) {

            self.secretKey = secretKey;

            self.encryptor = encryptor;

            self.encryptedSymmetricKey = encryptedSymmetricKey;
            
            TDLogDebug(@"\n****************secretKey****************\n public key: %@ \n encrypted symmetric key: %@\n****************secretKey****************", secretKey.publicKey, encryptedSymmetricKey);
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

- (BOOL)needUpdateSecretKey:(TDSecretKey *)oldSecretKey newSecretKey:(TDSecretKey *)newSecretKey {
    if (oldSecretKey.version != newSecretKey.version) {
        return NO;
    }
    if (![oldSecretKey.publicKey isEqualToString:newSecretKey.publicKey]) {
        return NO;
    }
    if (![oldSecretKey.symmetricEncryption isEqualToString:newSecretKey.symmetricEncryption]) {
        return NO;
    }
    if (![oldSecretKey.asymmetricEncryption isEqualToString:newSecretKey.asymmetricEncryption]) {
        return NO;
    }
    return YES;
}

- (id<TDEncryptProtocol>)filterEncrptor:(TDSecretKey *)secretKey {
    id<TDEncryptProtocol> encryptor = [self encryptorWithSecretKey:secretKey];
    if (!encryptor) {
        NSString *format = @"\n You have used the [%@] key, but the corresponding encryption plugin has not been registered. \n";
        NSString *type = [NSString stringWithFormat:@"%@+%@", secretKey.asymmetricEncryption, secretKey.symmetricEncryption];
        NSString *message = [NSString stringWithFormat:format, type];
        NSAssert(NO, message);
        return nil;
    }
    return encryptor;
}

- (id<TDEncryptProtocol>)encryptorWithSecretKey:(TDSecretKey *)secretKey {
    if (!secretKey) {
        return nil;
    }
    __block id<TDEncryptProtocol> encryptor;
    [self.encryptors enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<TDEncryptProtocol> obj, NSUInteger idx, BOOL *stop) {
        BOOL isSameAsymmetricType = [[obj asymmetricEncryptType] isEqualToString:secretKey.asymmetricEncryption];
        BOOL isSameSymmetricType = [[obj symmetricEncryptType] isEqualToString:secretKey.symmetricEncryption];
        if (isSameAsymmetricType && isSameSymmetricType) {
            encryptor = obj;
            *stop = YES;
        }
    }];
    return encryptor;
}

- (NSDictionary *)encryptJSONObject:(NSDictionary *)obj {
    @try {
        if (!obj) {
            TDLogDebug(@"Enable encryption but the input obj is invalid!");
            return nil;
        }

        if (!self.encryptor) {
            TDLogDebug(@"Enable encryption but the secret key is invalid!");
            return nil;
        }

        if (![self encryptSymmetricKey]) {
            TDLogDebug(@"Enable encryption but encrypt symmetric key is failed!");
            return nil;
        }

        
        NSData *jsonData = [TDJSONUtil JSONSerializeForObject:obj];

        
        NSString *encryptedString =  [self.encryptor encryptEvent:jsonData];
        if (!encryptedString) {
            TDLogDebug(@"Enable encryption but encrypted input obj is invalid!");
            return nil;
        }

        
        NSMutableDictionary *secretObj = [NSMutableDictionary dictionary];
        secretObj[@"pkv"] = @(self.secretKey.version);
        secretObj[@"ekey"] = self.encryptedSymmetricKey;
        secretObj[@"payload"] = encryptedString;
        return [NSDictionary dictionaryWithDictionary:secretObj];
    } @catch (NSException *exception) {
        TDLogDebug(@"%@ error: %@", self, exception);
        return nil;
    }
}


- (BOOL)encryptSymmetricKey {
    if (self.encryptedSymmetricKey) {
        return YES;
    }
    NSString *publicKey = self.secretKey.publicKey;
    self.encryptedSymmetricKey = [self.encryptor encryptSymmetricKeyWithPublicKey:publicKey];
    return self.encryptedSymmetricKey != nil;
}

- (BOOL)isValid {
    return _encryptor ? YES:NO;
}

@end
