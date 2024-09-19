//
//  TDFile.m
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import "TDFile.h"
#import "TDLogging.h"
#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif

@implementation TDFile

- (instancetype)initWithAppid:(NSString*)appid
{
    self = [super init];
    if(self)
    {
        self.appid = appid;
    }
    return self;
}

- (void)archiveSessionID:(long long)sessionid {
    NSString *filePath = [self sessionIdFilePath];
    if (![self archiveObject:@(sessionid) withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive identifyId", self);
    }
}
- (long long)unarchiveSessionID {
    return [[self unarchiveFromFile:[self sessionIdFilePath] asClass:[NSNumber class]] longLongValue];
}


- (void)archiveIdentifyId:(NSString *)identifyId {
    
    NSString *filePath = [self identifyIdFilePath];
    if (![self archiveObject:[identifyId copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive identifyId", self);
    }
}

- (NSString*)unarchiveIdentifyID {
    return [self unarchiveFromFile:[self identifyIdFilePath] asClass:[NSString class]];
}

- (NSString*)unarchiveAccountID {
    return [self unarchiveFromFile:[self accountIDFilePath] asClass:[NSString class]];
}

- (void)archiveUploadSize:(NSNumber *)uploadSize {
    NSString *filePath = [self uploadSizeFilePath];
    if (![self archiveObject:uploadSize withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive uploadSize", self);
    }
}
- (NSNumber*)unarchiveUploadSize {
    NSNumber*  uploadSize = [self unarchiveFromFile:[self uploadSizeFilePath] asClass:[NSNumber class]];
    if (!uploadSize) {
        uploadSize = [NSNumber numberWithInteger:30];
    }
    return uploadSize;
}

- (void)archiveUploadInterval:(NSNumber *)uploadInterval {
    NSString *filePath = [self uploadIntervalFilePath];
    if (![self archiveObject:uploadInterval withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive uploadInterval", self);
    }
}

- (NSNumber*)unarchiveUploadInterval {
    NSNumber* uploadInterval = [self unarchiveFromFile:[self uploadIntervalFilePath] asClass:[NSNumber class]];
    if (!uploadInterval) {
        uploadInterval = [NSNumber numberWithInteger:30];
    }
    return uploadInterval;
}

- (void)archiveAccountID:(NSString *)accountID {
    NSString *filePath = [self accountIDFilePath];
    if (![self archiveObject:[accountID copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive accountID", self);
    }
}

- (void)archiveSuperProperties:(NSDictionary *)superProperties {
    NSString *filePath = [self superPropertiesFilePath];
    if (![self archiveObject:[superProperties copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive superProperties", self);
    }
}

- (NSDictionary*)unarchiveSuperProperties {
    return [self unarchiveFromFile:[self superPropertiesFilePath] asClass:[NSDictionary class]];
}

- (void)archiveTrackPause:(BOOL)trackPause {
    NSString *filePath = [self trackPauseFilePath];
    if (![self archiveObject:[NSNumber numberWithBool:trackPause] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive trackPause", self);
    }
}

- (BOOL)unarchiveTrackPause {
    NSNumber *trackPause = (NSNumber *)[self unarchiveFromFile:[self trackPauseFilePath] asClass:[NSNumber class]];
    return [trackPause boolValue];
}

- (void)archiveOptOut:(BOOL)optOut {
    NSString *filePath = [self optOutFilePath];
    if (![self archiveObject:[NSNumber numberWithBool:optOut] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive isOptOut", self);
    }
}

- (BOOL)unarchiveOptOut {
    NSNumber *optOut = (NSNumber *)[self unarchiveFromFile:[self optOutFilePath] asClass:[NSNumber class]];
    return [optOut boolValue];
}

- (void)archiveIsEnabled:(BOOL)isEnabled {
    NSString *filePath = [self enabledFilePath];
    if (![self archiveObject:[NSNumber numberWithBool:isEnabled] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive isEnabled", self);
    }
}

- (BOOL)unarchiveEnabled {
    NSNumber *enabled = (NSNumber *)[self unarchiveFromFile:[self enabledFilePath] asClass:[NSNumber class]];
    if (enabled == nil) {
       return YES;
    } else {
        return [enabled boolValue];
    }
}

- (void)archiveDeviceId:(NSString *)deviceId {
    NSString *filePath = [self deviceIdFilePath];
    if (![self archiveObject:[deviceId copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive deviceId", self);
    }
}

- (NSString *)unarchiveDeviceId {
    return [self unarchiveFromFile:[self deviceIdFilePath] asClass:[NSString class]];
}

- (void)archiveInstallTimes:(NSString *)installTimes {
    NSString *filePath = [self installTimesFilePath];
    if (![self archiveObject:[installTimes copy] withFilePath:filePath]) {
        TDLogError(@"%@ unable to archive installTimes", self);
    }
}

- (NSString *)unarchiveInstallTimes {
    return [self unarchiveFromFile:[self installTimesFilePath] asClass:[NSString class]];
}

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath {
    @try {
        if (![NSKeyedArchiver archiveRootObject:object toFile:filePath]) {
            return NO;
        }
    } @catch (NSException *exception) {
        TDLogError(@"Got exception: %@, reason: %@. You can only send to Thinking values that inherit from NSObject and implement NSCoding.", exception.name, exception.reason);
        return NO;
    }
    
    [self addSkipBackupAttributeToItemAtPath:filePath];
    return YES;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString {
    NSURL *URL = [NSURL fileURLWithPath:filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        TDLogError(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (id)unarchiveFromFile:(NSString *)filePath asClass:(Class)class {
    id unarchivedData = nil;
    @try {
        unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        if (![unarchivedData isKindOfClass:class]) {
            unarchivedData = nil;
        }
    }
    @catch (NSException *exception) {
        TDLogError(@"Error unarchive in %@", filePath);
        unarchivedData = nil;
        NSError *error = NULL;
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!removed) {
            TDLogDebug(@"Error remove file in %@, error: %@", filePath, error);
        }
    }
    return unarchivedData;
}

- (NSString *)superPropertiesFilePath {
    return [self persistenceFilePath:@"superProperties"];
}

- (NSString *)accountIDFilePath {
    return [self persistenceFilePath:@"accountID"];
}

- (NSString *)uploadSizeFilePath {
    return [self persistenceFilePath:@"uploadSize"];
}

- (NSString *)uploadIntervalFilePath {
    return [self persistenceFilePath:@"uploadInterval"];
}

- (NSString *)identifyIdFilePath {
    return [self persistenceFilePath:@"identifyId"];
}

- (NSString *)sessionIdFilePath {
    return [self persistenceFilePath:@"sessionId"];
}

- (NSString *)enabledFilePath {
    return [self persistenceFilePath:@"isEnabled"];
}

- (NSString *)trackPauseFilePath {
    return [self persistenceFilePath:@"trackPause"];
}

- (NSString *)optOutFilePath {
    return [self persistenceFilePath:@"optOut"];
}

- (NSString *)deviceIdFilePath {
    return [self persistenceFilePath:@"deviceId"];
}

- (NSString *)installTimesFilePath {
    return [self persistenceFilePath:@"installTimes"];
}

- (NSString *)persistenceFilePath:(NSString *)data{
    NSString *filename = [NSString stringWithFormat:@"thinking-%@-%@.plist", self.appid, data];
    return [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:filename];
}

- (NSString*)unarchiveOldLoginId {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"thinkingdata_accountId"];
}

- (void)deleteOldLoginId {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"thinkingdata_accountId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)description {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.appid forKey:@"appid"];
    [dic setObject:[self unarchiveIdentifyID]?:@"" forKey:@"distincid"];
    [dic setObject:[self unarchiveAccountID]?:@"" forKey:@"accountID"];
    [dic setObject:[self unarchiveUploadSize] forKey:@"uploadSize"];
    [dic setObject:[self unarchiveUploadInterval] forKey:@"uploadInterval"];
    [dic setObject:[self unarchiveSuperProperties]?:@{}  forKey:@"superProperties"];
    [dic setObject:[NSNumber numberWithBool:[self unarchiveOptOut] ]forKey:@"optOut"];
    [dic setObject:[NSNumber numberWithBool:[self unarchiveEnabled]] forKey:@"isEnabled"];
    [dic setObject:[NSNumber numberWithBool:[self unarchiveTrackPause]] forKey:@"isTrackPause"];
    [dic setObject:[self unarchiveDeviceId]?:@"" forKey:@"deviceId"];
    [dic setObject:[self unarchiveInstallTimes]?:@"" forKey:@"installTimes"];
    return [TDJSONUtil JSONStringForObject:dic];
}

@end
