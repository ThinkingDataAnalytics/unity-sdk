#import <Foundation/Foundation.h>
#import "TDConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface TDSecurityPolicy: NSObject<NSCopying>
/**
 是否允许自建证书或者过期SSL证书，默认 NO
*/
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 是否验证证书域名，默认 YES
*/
@property (nonatomic, assign) BOOL validatesDomainName;

/**
 自定义 HTTPS 认证
*/
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

/**
 证书验证模式
 
 @param pinningMode 证书验证模式
*/
+ (instancetype)policyWithPinningMode:(TDSSLPinningMode)pinningMode;

+ (instancetype)defaultPolicy;
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

@end

#ifndef __Require_Quiet
    #define __Require_Quiet(assertion, exceptionLabel)                            \
      do                                                                          \
      {                                                                           \
          if ( __builtin_expect(!(assertion), 0) )                                \
          {                                                                       \
              goto exceptionLabel;                                                \
          }                                                                       \
      } while ( 0 )
#endif

#ifndef __Require_noErr_Quiet
    #define __Require_noErr_Quiet(errorCode, exceptionLabel)                      \
      do                                                                          \
      {                                                                           \
          if ( __builtin_expect(0 != (errorCode), 0) )                            \
          {                                                                       \
              goto exceptionLabel;                                                \
          }                                                                       \
      } while ( 0 )
#endif


NS_ASSUME_NONNULL_END
