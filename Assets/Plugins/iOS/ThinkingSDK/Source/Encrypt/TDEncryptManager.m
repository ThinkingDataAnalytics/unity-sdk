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
#import "NSData+TDGzip.h"
#import "TDJSONUtil.h"
#import "TDEventRecord.h"
#import "TDLogging.h"


@interface TDEncryptManager ()

@property (nonatomic, strong) TDConfig *config;
@property (nonatomic, strong) id<TDEncryptProtocol> encryptor;
@property (nonatomic, copy) NSArray<id<TDEncryptProtocol>> *encryptors;
@property (nonatomic, copy) NSString *encryptedSymmetricKey;
@property (nonatomic, strong) TDSecretKey *secretKey;

@end

@implementation TDEncryptManager

- (instancetype)initWithConfig:(TDConfig *)config
{
    self = [super init];
    if (self) {
        [self updateConfig:config];
    }
    return self;
}

- (void)updateConfig:(TDConfig *)config {
    self.config = config;
    
    /// 加载所有加密插件
    NSMutableArray *encryptors = [NSMutableArray array];
    [encryptors addObject:[TDRSAEncryptorPlugin new]];
    self.encryptors = encryptors;
    
    /// 获取当前加密插件
    [self updateEncryptor:[self loadCurrentSecretKey]];
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
    
    // 插件不可用
    if (![secretKey isValid]) {
        return;
    }
    
    // 没有加密插件
    if (![self encryptorWithSecretKey:secretKey]) {
        return;
    }
    
    // 更新加密构造器
    [self updateEncryptor:secretKey];
}

// 根据密钥 -> 筛选出合适的加密组件 -> 更新内存中加密插件
- (void)updateEncryptor:(TDSecretKey *)obj {
    @try {
        // 加载密钥
        TDSecretKey *secretKey = obj;
        if (!secretKey.publicKey.length) {
            return;
        }

        // 是否需要更新密钥信息
        if ([self needUpdateSecretKey:self.secretKey newSecretKey:secretKey]) {
            return;
        }

        // 筛选出合适的加密组件
        id<TDEncryptProtocol> encryptor = [self filterEncrptor:secretKey];
        if (!encryptor) {
            return;
        }

        // 保存加密后的对称密钥数据
        NSString *encryptedSymmetricKey = [encryptor encryptSymmetricKeyWithPublicKey:secretKey.publicKey];
        
        if (encryptedSymmetricKey.length) {
            // 更新密钥
            self.secretKey = secretKey;
            // 更新加密插件
            self.encryptor = encryptor;
            // 重新生成加密插件的对称密钥
            self.encryptedSymmetricKey = encryptedSymmetricKey;
            
            TDLogDebug(@"\n****************secretKey****************\n公钥: %@ \n加密的对称密钥: %@\n****************secretKey****************", secretKey.publicKey, encryptedSymmetricKey);
        }
    } @catch (NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
}

- (TDSecretKey *)loadCurrentSecretKey {
    TDSecretKey *secretKey = self.config.secretKey;
    return secretKey;
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
        NSString *format = @"\n您使用了 [%@]  密钥，但是并没有注册对应加密插件。\n • 若您使用的是 EC+AES 或 SM2+SM4 加密方式，请检查是否正确集成 'SensorsAnalyticsEncrypt' 模块，且已注册对应加密插件。\n";
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

        // JSON字符串
        NSData *jsonData = [TDJSONUtil JSONSerializeForObject:obj];

        // 加密数据
        NSString *encryptedString =  [self.encryptor encryptEvent:jsonData];
        if (!encryptedString) {
            TDLogDebug(@"Enable encryption but encrypted input obj is invalid!");
            return nil;
        }

        // 封装加密的数据结构
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
