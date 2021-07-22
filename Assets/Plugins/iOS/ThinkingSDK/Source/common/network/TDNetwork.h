#import <Foundation/Foundation.h>

#import "ThinkingAnalyticsSDKPrivate.h"


typedef void (^TDFlushConfigBlock)(NSDictionary *result, NSError * _Nullable error);

@interface TDNetwork : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
/**
 应用唯一标识
 */
@property (nonatomic, copy) NSString *appid;
/**
 私有化服务器地址
 */
@property (nonatomic, strong) NSURL *serverURL;

@property (nonatomic, strong) NSURL *serverDebugURL;
@property (nonatomic, assign) ThinkingAnalyticsDebugMode debugMode;
@property (nonatomic, strong) TDSecurityPolicy *securityPolicy;
@property (nonatomic, copy) TDURLSessionDidReceiveAuthenticationChallengeBlock sessionDidReceiveAuthenticationChallenge;

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)events;
- (void)fetchRemoteConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler;
- (int)flushDebugEvents:(NSDictionary *)record withAppid:(NSString *)appid;

@end

