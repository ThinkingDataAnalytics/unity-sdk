//
//  TDNotificationManager+RemoteConfig.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/2.
//

#import "TDNotificationManager+RemoteConfig.h"

NSString * const kRemoteConfigNotificationNameTemplateWillStop = @"kRemoteConfigNotificationNameTemplateWillStop";
NSString * const kRemoteConfigNotificationNameTemplateFetchSuccess = @"kRemoteConfigNotificationNameTemplateFetchSuccess";
NSString * const kRemoteConfigNotificationNameTemplateFetchFailed = @"kRemoteConfigNotificationNameTemplateFetchFailed";
NSString * const kRemoteConfigNotificationParamAppId = @"appId";
NSString * const kRemoteConfigNotificationParamTemplateCode = @"templateCode";
NSString * const kRemoteConfigNotificationParamClientUserId = @"clientUserId";
NSString * const kRemoteConfigNotificationParamTemplateInfo = @"templateInfo";
NSString * const kRemoteConfigNotificationParamErrorCode = @"errorCode";
NSString * const kRemoteConfigNotificationParamIsDebug = @"isDebug";

NSString * const kRemoteConfigNotificationNameSystemConfigFetchSuccess = @"kRemoteConfigNotificationNameSystemConfigFetchSuccess";
NSString * const kRemoteConfigNotificationParamSystemConfig = @"kRemoteConfigNotificationParamSystemConfig";

@implementation TDNotificationManager (RemoteConfig)

+ (void)postRemoteConfigWillStopTemplateCode:(NSString *)templateCode appId:(NSString *)appId clientUserId:(NSString *)clientUserId {
    if (templateCode.length == 0 || appId.length == 0 || clientUserId.length == 0) {
        return;
    }
    NSDictionary *userInfo = @{
        kRemoteConfigNotificationParamAppId: appId,
        kRemoteConfigNotificationParamTemplateCode: templateCode,
        kRemoteConfigNotificationParamClientUserId: clientUserId
    };
    [self postNotificationName:kRemoteConfigNotificationNameTemplateWillStop object:nil userInfo:userInfo];
}

+ (void)postRemoteConfigFetchTemplateSuccessIsDebug:(BOOL)isDebug templateCode:(NSString *)templateCode appId:(NSString *)appId clientUserId:(NSString *)clientUserId templateInfo:(NSDictionary *)templateInfo {
    if (templateCode.length == 0 || appId.length == 0 || clientUserId.length == 0 || templateInfo.count == 0) {
        return;
    }
    NSDictionary *userInfo = @{
        kRemoteConfigNotificationParamAppId: appId,
        kRemoteConfigNotificationParamTemplateCode: templateCode,
        kRemoteConfigNotificationParamClientUserId: clientUserId,
        kRemoteConfigNotificationParamTemplateInfo: templateInfo,
        kRemoteConfigNotificationParamIsDebug: @(isDebug),
    };
    [self postNotificationName:kRemoteConfigNotificationNameTemplateFetchSuccess object:nil userInfo:userInfo];
}

+ (void)postRemoteConfigFetchTemplateFailedIsDebug:(BOOL)isDebug templateCode:(NSString *)templateCode appId:(NSString *)appId clientUserId:(NSString *)clientUserId errorCode:(NSNumber *)errorCode {
    if (templateCode.length == 0 || appId.length == 0 || clientUserId.length == 0 || errorCode == nil) {
        return;
    }
    NSDictionary *userInfo = @{
        kRemoteConfigNotificationParamAppId: appId,
        kRemoteConfigNotificationParamTemplateCode: templateCode,
        kRemoteConfigNotificationParamClientUserId: clientUserId,
        kRemoteConfigNotificationParamErrorCode: errorCode,
        kRemoteConfigNotificationParamIsDebug: @(isDebug),
    };
    [self postNotificationName:kRemoteConfigNotificationNameTemplateFetchFailed object:nil userInfo:userInfo];
}

+ (void)postRemoteConfigFetchSystemConfigSuccessWithAppId:(NSString *)appId systemConfig:(nullable NSDictionary *)systemConfig {
    if (appId.length == 0) {
        return;
    }
    NSMutableDictionary *userInfo = [@{
        kRemoteConfigNotificationParamAppId: appId,
    } mutableCopy];
    if ([systemConfig isKindOfClass:NSDictionary.class]) {
        userInfo[kRemoteConfigNotificationParamSystemConfig] = systemConfig;
    }
    [self postNotificationName:kRemoteConfigNotificationNameSystemConfigFetchSuccess object:nil userInfo:userInfo];
}

@end
