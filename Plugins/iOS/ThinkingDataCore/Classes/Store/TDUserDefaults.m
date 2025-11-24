//
//  TDUserDefaults.m
//  ThinkingDataCore
//
//  Created by 廖德生 on 2024/10/29.
//

#import "TDUserDefaults.h"
#if TARGET_OS_IOS
#import "TDStorageEncryptPlugin.h"
#endif

@implementation TDUserDefaults

+ (instancetype)standardUserDefaults {
    static dispatch_once_t onceToken;
    static TDUserDefaults *userDefault = nil;
    dispatch_once(&onceToken, ^{
        userDefault = [[TDUserDefaults alloc] init];
    });
    return userDefault;
}

- (void)setBool:(BOOL)value forKey:(nonnull NSString *)defaultName {
#if TARGET_OS_IOS
    id encryptValue = [[TDStorageEncryptPlugin sharedInstance] encryptDataIfNeed:@(value)];
    [[NSUserDefaults standardUserDefaults] setObject:encryptValue forKey:defaultName];
#else
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:defaultName];
#endif
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
#if TARGET_OS_IOS
    id encryptValue = [[TDStorageEncryptPlugin sharedInstance] encryptDataIfNeed:value];
    [[NSUserDefaults standardUserDefaults] setObject:encryptValue forKey:defaultName];
#else
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
#endif
}

- (void)setString:(NSString *)value forKey:(NSString *)defaultName {
    [self setObject:value forKey:defaultName];
}

- (void)removeObjectForKey:(nonnull NSString *)defaultName {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultName];
}

- (NSString *)stringForKey:(NSString *)defaultName {
    return [self objectForKey:defaultName];
}

- (id)objectForKey:(NSString *)defaultName {
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:defaultName];
#if TARGET_OS_IOS
    id decryptValue = [[TDStorageEncryptPlugin sharedInstance] decryptDataIfNeed:value];
    // Re-encrypt the data and store it
    if ([[TDStorageEncryptPlugin sharedInstance] isEnableEncrypt]) {
        if (value != nil) {
            if (([value isKindOfClass:[NSString class]] && [value hasPrefix:TDStorageEncryptStringPrefix]) == NO) {
                [[TDUserDefaults standardUserDefaults] setObject:value forKey:defaultName];
            }
        }
    }
    return decryptValue;
#else
    return value;
#endif
}

- (void)synchronize {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
