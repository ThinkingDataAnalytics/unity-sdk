//
//  TDAnalyticsAppGroupManager.m
//  ThinkingSDK.default-TDCore-iOS
//
//  Created by 杨雄 on 2023/7/3.
//
//  AppGroup 中存放 thinking_data.plist 文件，内容为：
//  {
//     "appId_123": {
//          "accountId": "123"
//          "distinctId": "123"
//          "deviceId": "123"
//          "receiveUrl": "123"
//          "extension_event_cache": [
//              "event json string",
//              "event json string"
//          ]
//     }
//  }
//

#import "TDAnalyticsAppGroupManager.h"
#import "TDAnalyticsAppGroupModel.h"

static NSString * const kTDAppGroupConfigFileName = @"thinking_data.plist";

@interface TDAnalyticsAppGroupManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, TDAnalyticsAppGroupModel *> *analytics;

@end

@implementation TDAnalyticsAppGroupManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TDAnalyticsAppGroupManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[TDAnalyticsAppGroupManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.analytics = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString * _Nullable)filePathForApplicationGroup {
    if (self.appGroupName.length) {
        NSURL *pathUrl = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:self.appGroupName] URLByAppendingPathComponent:kTDAppGroupConfigFileName];
        return pathUrl.path;
    }
    return nil;
}

- (void)readDataFromAppGroup {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [self filePathForApplicationGroup];
        if (!path) return;
        if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
            [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:attributes];
        }
        
        NSDictionary *appGroupDict = [[NSDictionary alloc] initWithContentsOfFile:path];
        NSArray<NSString *> *keys = appGroupDict.allKeys;
        for (NSInteger i = 0; i < keys.count; i++) {
            NSString *appId = keys[i];
            NSDictionary *analyticsDict = appGroupDict[appId];
            TDAnalyticsAppGroupModel *model = [[TDAnalyticsAppGroupModel alloc] initWithAppId:appId dictionary:analyticsDict];
            if (model) {
                self.analytics[appId] = model;
            }
        }
    });
}

- (void)syncDataToAppGroup {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSArray<NSString *> *keys = self.analytics.allKeys;
    for (NSInteger i = 0; i < keys.count; i++) {
        NSString *appId = keys[i];
        NSDictionary *analyticsDict = self.analytics[appId].jsonDict;
        if (analyticsDict) {
            params[appId] = analyticsDict;
        }
    }
    
    NSString *path = [self filePathForApplicationGroup];
    if (!path) return;
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:attributes];
    }
    
    NSData *data= [NSPropertyListSerialization dataWithPropertyList:params format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    if (path.length && data.length) {
        [data writeToFile:path options:NSDataWritingAtomic error:nil];
    }
}

//MARK: - public

- (void)setAppGroupName:(NSString *)appGroupName {
    _appGroupName = appGroupName;
    
    [self readDataFromAppGroup];
}

- (void)clearEventCacheWithAppId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return;
    }
    
    TDAnalyticsAppGroupModel *analytic = self.analytics[appId];
    [analytic.eventCache removeAllObjects];
    [self syncDataToAppGroup];
}

- (NSArray<NSDictionary *> *)getExtensionEventCacheWithAppId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return nil;
    }
    
    TDAnalyticsAppGroupModel *analytic = self.analytics[appId];
    return analytic.eventCache;
}

- (void)setAccountId:(NSString * _Nullable)accountId appId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return;
    }
    
    TDAnalyticsAppGroupModel *analytic = [self analyticsInstanceWithAppId:appId];
    analytic.accountId = accountId;
    [self syncDataToAppGroup];
}

- (void)setDeviceId:(nonnull NSString *)deviceId appId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return;
    }
    
    TDAnalyticsAppGroupModel *analytic = [self analyticsInstanceWithAppId:appId];
    analytic.deviceId = deviceId;
    [self syncDataToAppGroup];
}

- (void)setReceiveUrl:(nonnull NSString *)url appId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return;
    }
    
    TDAnalyticsAppGroupModel *analytic = [self analyticsInstanceWithAppId:appId];
    analytic.receiveUrl = url;
    [self syncDataToAppGroup];
}

- (void)setDistinctId:(nonnull NSString *)distinctId appId:(nonnull NSString *)appId {
    if (self.isEnableAppGroup == NO) {
        return;
    }
    
    TDAnalyticsAppGroupModel *analytic = [self analyticsInstanceWithAppId:appId];
    analytic.distinctId = distinctId;
    [self syncDataToAppGroup];
}

//MARK: - private

- (BOOL)isEnableAppGroup {
    NSString *path = [self filePathForApplicationGroup];
    return path.length > 0;
}

- (TDAnalyticsAppGroupModel * _Nullable)analyticsInstanceWithAppId:(NSString *)appId {
    if (!appId) {
        return nil;
    }
    TDAnalyticsAppGroupModel *analytic = self.analytics[appId];
    if (!analytic) {
        analytic = [[TDAnalyticsAppGroupModel alloc] init];
        analytic.appId = appId;
        self.analytics[appId] = analytic;
    }
    return analytic;
}

@end
