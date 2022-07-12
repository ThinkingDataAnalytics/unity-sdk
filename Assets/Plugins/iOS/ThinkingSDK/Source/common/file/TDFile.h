//
//  TDFile.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDFile : NSObject

// 此处的appid已经不是当初的appid了，do you kown instanceName?
// TDFile中的唯一标识是实例名字或appid
// 实例名字存在的情况下，优先使用实例名字来作为文件的唯一标识
@property(strong,nonatomic) NSString* appid;

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

- (void)archiveOptOut:(BOOL)optOut;
- (BOOL)unarchiveOptOut;

- (void)archiveIsEnabled:(BOOL)isEnabled;
- (BOOL)unarchiveEnabled;

- (void)archiveDeviceId:(NSString *)deviceId;
- (NSString *)unarchiveDeviceId;

- (void)archiveInstallTimes:(NSString *)installTimes;
- (NSString *)unarchiveInstallTimes;

- (BOOL)archiveObject:(id)object withFilePath:(NSString *)filePath;

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString;
// 兼容老版本
- (NSString*)unarchiveOldLoginId;
// 兼容老版本
- (void)deleteOldLoginId;

@end;

NS_ASSUME_NONNULL_END
