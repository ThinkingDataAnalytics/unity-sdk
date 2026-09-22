#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDAnalyticsNetwork : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, strong) NSURL *serverURL;

@property (nonatomic, strong) NSURL *serverDebugURL;
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)events;

- (void)fetchRemoteConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;
- (int)flushDebugEvents:(NSDictionary *)record appid:(NSString *)appid isDebugOnly:(BOOL)isDebugOnly;
- (void)fetchIPMap;

+ (void)enableDNSServcie:(NSArray<TDDNSService> *)services;

@end

NS_ASSUME_NONNULL_END

