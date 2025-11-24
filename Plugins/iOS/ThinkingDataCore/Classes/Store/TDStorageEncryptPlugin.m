//
//  TDStorageEncryptPlugin.m
//  ThinkingDataCore
//
//  Created by 廖德生 on 2024/10/29.
//

#import "TDStorageEncryptPlugin.h"
#import "TDAESEncryptor.h"
#import "TDJSONUtil.h"

static NSString * const TDStorageEncryptAESKey = @"thinking-data-analytics";
NSString * const TDStorageEncryptStringPrefix = @"TDEncryptPrefix_";
static NSString * const TDStorageEncryptFileSuffix = @".enc";

@interface TDStorageEncryptPlugin()
@property (nonatomic, assign) BOOL encryptFlag;
@property (nonatomic, strong) TDAESEncryptor *encryptor;

@end

@implementation TDStorageEncryptPlugin

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TDStorageEncryptPlugin *plugin = nil;
    dispatch_once(&onceToken, ^{
        plugin = [[TDStorageEncryptPlugin alloc] init];
    });
    return plugin;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        TDAESEncryptor *encryptor = [[TDAESEncryptor alloc] init];
        encryptor.key = TDStorageEncryptAESKey;
        self.encryptor = encryptor;
    }
    return self;
}

- (void)enableEncrypt {
    self.encryptFlag = YES;
}

- (BOOL)isEnableEncrypt {
    return self.encryptFlag;
}

- (id)encryptDataIfNeed:(id)data {
    if (!data) {
        return nil;
    }
    if (self.encryptFlag) {
        NSError *err = nil;
        NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
        if (plistData != nil && err == nil) {
            NSData *encryptData = [self.encryptor encryptData:plistData];
            NSString *encryptStr = [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
            return [NSString stringWithFormat:@"%@%@", TDStorageEncryptStringPrefix, encryptStr];
        }
    }
    return data;
}

- (id)decryptDataIfNeed:(id)data {
    if (!data) {
        return nil;
    }
    if ([data isKindOfClass:[NSString class]]) {
        NSString *strValue = data;
        if ([strValue hasPrefix:TDStorageEncryptStringPrefix]) {
            NSString *encryptStr = [strValue substringFromIndex:TDStorageEncryptStringPrefix.length];
            NSData *encryptData = [[NSData alloc] initWithBase64EncodedString:encryptStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSData *decryptData = [self.encryptor decryptData:encryptData];
            
            data = [NSPropertyListSerialization propertyListWithData:decryptData options:NSPropertyListMutableContainersAndLeaves format:NULL error:nil];
        }
        return data;
    }
    return data;
}

- (nullable NSString *)encryptFileAtPathIfNeed:(NSString *)filePath {
    NSString *encryptedPath = [filePath stringByAppendingString:TDStorageEncryptFileSuffix];
    
    if (!self.encryptFlag) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:encryptedPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:encryptedPath error:nil];
        }
        return filePath;
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData) {
        return nil;
    }
    NSData *encryptedData = [self.encryptor encryptData:fileData];
    if (!encryptedData) {
        return nil;
    }
    
    BOOL success = [encryptedData writeToFile:encryptedPath atomically:YES];
    if (!success) {
        return nil;
    }
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    return encryptedPath;
}

- (NSData *)decryptFileAtPath:(NSString *)filePath {
    NSString *encryptedPath = [filePath stringByAppendingString:TDStorageEncryptFileSuffix];
    if (![[NSFileManager defaultManager] fileExistsAtPath:encryptedPath]) {
        return nil;
    }
    
    NSData *encryptedData = [NSData dataWithContentsOfFile:encryptedPath];
    if (!encryptedData) {
        return nil;
    }

    // decrypt data
    NSData *decryptedData = [self.encryptor decryptData:encryptedData];
    
    // If encryption is disabled, the file is returned to unencrypted
    if (!self.encryptFlag) {
        BOOL ok = [decryptedData writeToFile:filePath atomically:YES];
        if (ok) {
            [[NSFileManager defaultManager] removeItemAtPath:encryptedPath error:nil];
        }
    }
    return decryptedData;
}

@end
