//
//  TDNotificationManager+RemoteConfig.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/2.
//

#if __has_include(<ThinkingDataCore/TDNotificationManager.h>)
#import <ThinkingDataCore/TDNotificationManager.h>
#else
#import "TDNotificationManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kRemoteConfigNotificationNameTemplateWillStop;
extern NSString * const kRemoteConfigNotificationNameTemplateFetchSuccess;
extern NSString * const kRemoteConfigNotificationNameTemplateFetchFailed;
extern NSString * const kRemoteConfigNotificationParamAppId;
extern NSString * const kRemoteConfigNotificationParamTemplateCode;
extern NSString * const kRemoteConfigNotificationParamClientUserId;
extern NSString * const kRemoteConfigNotificationParamTemplateInfo;
extern NSString * const kRemoteConfigNotificationParamErrorCode;
extern NSString * const kRemoteConfigNotificationParamIsDebug;

extern NSString * const kRemoteConfigNotificationNameSystemConfigFetchSuccess;
extern NSString * const kRemoteConfigNotificationParamSystemConfig;

@interface TDNotificationManager (RemoteConfig)

+ (void)postRemoteConfigWillStopTemplateCode:(nonnull NSString *)templateCode appId:(nonnull NSString *)appId clientUserId:(nonnull NSString *)clientUserId;

+ (void)postRemoteConfigFetchTemplateSuccessIsDebug:(BOOL)isDebug templateCode:(nonnull NSString *)templateCode appId:(nonnull NSString *)appId clientUserId:(nonnull NSString *)clientUserId templateInfo:(nonnull NSDictionary *)templateInfo;

+ (void)postRemoteConfigFetchTemplateFailedIsDebug:(BOOL)isDebug templateCode:(nonnull NSString *)templateCode appId:(nonnull NSString *)appId clientUserId:(nonnull NSString *)clientUserId errorCode:(NSNumber *)errorCode;

+ (void)postRemoteConfigFetchSystemConfigSuccessWithAppId:(nonnull NSString *)appId systemConfig:(nullable NSDictionary *)systemConfig;


@end

NS_ASSUME_NONNULL_END
