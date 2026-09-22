//
//  TDSecretKey.m
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import "TDSecretKey.h"

@interface TDSecretKey ()

@property (nonatomic, assign) NSUInteger version;
@property (nonatomic, copy) NSString *publicKey;
@property (nonatomic, copy) NSString *symmetricEncryption;
@property (nonatomic, copy) NSString *asymmetricEncryption;

@end

@implementation TDSecretKey


- (instancetype)initWithVersion:(NSUInteger)version
                      publicKey:(NSString *)publicKey {
    
    return [[TDSecretKey alloc] initWithVersion:version
                                      publicKey:publicKey
                           asymmetricEncryption:@"RSA"
                            symmetricEncryption:@"AES"];
}

- (instancetype)initWithVersion:(NSUInteger)version
                      publicKey:(NSString *)publicKey
           asymmetricEncryption:(NSString *)asymmetricEncryption
            symmetricEncryption:(NSString *)symmetricEncryption {
    self = [super init];
    if (self) {
        self.version = version;
        self.publicKey = publicKey;
        self.asymmetricEncryption = asymmetricEncryption;
        self.symmetricEncryption = symmetricEncryption;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.version forKey:@"version"];
    [coder encodeObject:self.publicKey forKey:@"publicKey"];
    [coder encodeObject:self.symmetricEncryption forKey:@"symmetricEncrypt"];
    [coder encodeObject:self.asymmetricEncryption forKey:@"asymmetricEncrypt"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.version = [coder decodeIntegerForKey:@"version"];
        self.publicKey = [coder decodeObjectForKey:@"publicKey"];
        self.symmetricEncryption = [coder decodeObjectForKey:@"symmetricEncrypt"];
        self.asymmetricEncryption = [coder decodeObjectForKey:@"asymmetricEncrypt"];
    }
    return self;
}

- (BOOL)isValid {
    if (self.publicKey.length && self.symmetricEncryption.length && self.asymmetricEncryption.length) {
        return YES;
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    TDSecretKey *secretKey = [[[self class] allocWithZone:zone] init];
    secretKey.version = self.version;
    secretKey.publicKey = [self.publicKey copy];
    secretKey.symmetricEncryption = [self.symmetricEncryption copy];
    secretKey.asymmetricEncryption = [self.asymmetricEncryption copy];
    return secretKey;
}


@end
