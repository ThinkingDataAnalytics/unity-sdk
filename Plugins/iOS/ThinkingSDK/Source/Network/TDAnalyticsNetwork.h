#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDAnalyticsNetwork : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, strong) NSURL *serverURL;

@property (nonatomic, strong) NSURL *serverDebugURL;
@property (nonatomic, assign) TDMode mode;
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)events;

//- (void)flushEvents:(NSArray<NSDictionary *> *)recordArray completion:(nullable void(^)(BOOL))completion;
- (void)fetchRemoteConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;
- (int)flushDebugEvents:(NSDictionary *)record withAppid:(NSString *)appid;

- (void)fetchIPMap;

+ (void)enableDNSServcie:(NSArray<TDDNSService> *)services;

@end

NS_ASSUME_NONNULL_END

