//
//  TDFile.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDFile : NSObject

- (instancetype)initWithAppid:(NSString*)appid;

- (void)archiveIdentifyId:(nullable NSString *)identifyId;
- (NSString*)unarchiveIdentifyID ;

- (void)archiveAccountID:(nullable NSString *)accountID;
- (NSString*)unarchiveAccountID ;

- (void)archiveUploadSize:(NSNumber *)uploadSize;
- (NSNumber*)unarchiveUploadSize;

- (void)archiveUploadInterval:(NSNumber *)uploadInterval;
- (NSNumber*)unarchiveUploadInterval;

- (void)archiveSuperProperties:(nullable NSDictionary *)superProperties;
- (NSDictionary*)unarchiveSuperProperties;

// Read old information. Starting with version 3.2.0, the function 'archiveTrackStatus' is used
- (BOOL)unarchiveTrackPause;
- (BOOL)unarchiveOptOut;
- (BOOL)unarchiveEnabled;

- (void)archiveTrackStatus:(TDTrackStatus)trackStatus;
- (nullable NSNumber *)unarchiveTrackStatus;

- (void)archiveDeviceId:(NSString *)deviceId;
- (NSString *)unarchiveDeviceId;

- (void)archiveInstallTimes:(NSString *)installTimes;
- (NSString *)unarchiveInstallTimes;

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath;

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;

@end;

NS_ASSUME_NONNULL_END
