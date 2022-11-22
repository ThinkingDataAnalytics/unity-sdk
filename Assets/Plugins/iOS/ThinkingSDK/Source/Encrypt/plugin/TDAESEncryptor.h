//
//  TDAESEncryptor.h
//  ThinkingSDK
//
//  Created by wwango on 2022/1/21.
//

#import <Foundation/Foundation.h>
#import "TDEncryptAlgorithm.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAESEncryptor : NSObject <TDEncryptAlgorithm>

@property (nonatomic, copy, readonly) NSData *key;

@end

NS_ASSUME_NONNULL_END
