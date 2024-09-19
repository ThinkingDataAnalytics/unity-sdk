//
//  TDEncryptManager.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.


#import <Foundation/Foundation.h>

@class TDSecretKey;

NS_ASSUME_NONNULL_BEGIN

@interface TDEncryptManager : NSObject


@property(nonatomic, assign, getter=isValid) BOOL valid;


- (instancetype)initWithSecretKey:(TDSecretKey *)secretKey;

- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig;


- (NSDictionary *)encryptJSONObject:(NSDictionary *)obj;

@end

NS_ASSUME_NONNULL_END
