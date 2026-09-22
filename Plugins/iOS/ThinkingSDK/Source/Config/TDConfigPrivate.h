//
//  TDConfigPrivate.h
//  Pods
//
//  Created by 杨雄 on 2023/8/15.
//

#if __has_include(<ThinkingSDK/TDConfig.h>)
#import <ThinkingSDK/TDConfig.h>
#else
#import "TDConfig.h"
#endif

#ifndef TDConfigPrivate_h
#define TDConfigPrivate_h

@interface TDConfig ()
@property (atomic, assign) BOOL innerEnableEncrypt;
/// DNS service url for fetching ips
@property (atomic, copy) NSArray<TDDNSService> *dnsServices;

#if TARGET_OS_IOS
@property (nonatomic, strong) TDSecretKey *innerSecretKey;
#endif

- (ThinkingNetworkType)getNetworkType;
- (void)innerUpdateConfig:(void(^)(NSDictionary *dict))block;
- (NSString *)innerGetMapInstanceToken;
- (void)innerUpdateIPMap;

/// Whether remote config has confirmed AES-GCM support (`secret_key.mode` == gcm).
- (BOOL)isEncryptGcmSupported;

/// Parse `data.secret_key.mode` (case-insensitive `"gcm"`).
+ (BOOL)parseGcmSupportedFromConfigData:(nullable NSDictionary *)data;

/// Whether to log that encrypt was requested but the receiver lacks AES-GCM.
+ (BOOL)shouldLogEncryptWithoutGcm:(BOOL)enableEncrypt gcmSupported:(BOOL)gcmSupported;

@end

#endif /* TDConfigPrivate_h */
