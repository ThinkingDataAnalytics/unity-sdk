
/**
 Thinks AFNetworking: https://github.com/AFNetworking/AFNetworking
 */
#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDConstant.h>)
#import <ThinkingSDK/TDConstant.h>
#else
#import "TDConstant.h"
#endif

NS_ASSUME_NONNULL_BEGIN


@interface TDSecurityPolicy: NSObject<NSCopying>

@property (nonatomic, assign) BOOL allowInvalidCertificates;
@property (nonatomic, assign) BOOL validatesDomainName;
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;
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
