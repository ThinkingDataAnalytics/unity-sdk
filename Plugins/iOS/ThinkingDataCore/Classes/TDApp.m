//
//  TDApp.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/9/9.
//

#import "TDApp.h"
#import "TDJSONUtil.h"
#import "TDMediator+Analytics.h"
#import "TDMediator+RemoteConfig.h"
#import "TDMediator+Strategy.h"
#import "TDSettingsPrivate.h"
#import "TDCoreLog.h"
#import "NSString+TDCore.h"
#import "NSUrl+TDCore.h"

@implementation TDApp

+ (void)start {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"td_settings" ofType:@"json"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSArray *array = [TDJSONUtil jsonForData:data];
        if ([array isKindOfClass:NSArray.class]) {
            for (NSDictionary *projectInfo in array) {
                if ([projectInfo isKindOfClass:NSDictionary.class]) {
                    TDSettings *settings = [[TDSettings alloc] initWithDictionary:projectInfo];
                    [self startWithSetting:settings];
                }
            }
        } else {
            TDCORELOG(@"td_settings.json format is error");
        }
    } else {
        TDCORELOG(@"td_settings.json is not found");
    }
}

+ (void)startWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl {
    TDSettings *settings = [[TDSettings alloc] init];
    settings.appId = appId;
    settings.serverUrl = serverUrl;
    [TDApp startWithSetting:settings];
}

+ (void)startWithSetting:(TDSettings *)settings {
    // TDCore 日志打印开关
    [TDCoreLog enableLog:settings.enableLog];
    
    NSString *appId = nil;
    if ([settings.appId isKindOfClass:NSString.class]) {
        appId = [settings.appId td_trim];
    }
    if (appId.length == 0) {
        TDCORELOG(@"The app id is invalid");
        return;
    } else {
        settings.appId = appId;
    }
    
    NSString *serverUrl = nil;
    if ([settings.serverUrl isKindOfClass:NSString.class]) {
        serverUrl = [NSURL td_baseUrlStringWithString:settings.serverUrl];
    }
    if (serverUrl.length == 0) {
        TDCORELOG(@"The server url is invalid");
        return;
    } else {
        settings.serverUrl = serverUrl;
    }
    
    // 初始化采集SDK
    [[TDMediator sharedInstance] tdAnalyticsInitWithSettings:settings];
    // 初始化RemoteConfig SDK
    [[TDMediator sharedInstance] tdRemoteConfigInitWithSettings:settings];
    // 初始化策略SDK
    [[TDMediator sharedInstance] tdStrategyInitWithSettings:settings];
}

@end
