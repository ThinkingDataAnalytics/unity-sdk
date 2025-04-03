//
//  TDKeychainManager.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/23.
//

#import "TDKeychainManager.h"
#import "TDOSLog.h"

static NSString * const TDKeychainService = @"com.thinkingddata.analytics.service";

@interface TDKeychainManager ()

@end

@implementation TDKeychainManager

+ (void)saveItem:(nonnull NSString *)value forKey:(nonnull NSString *)key {
    if (!key || !value) {
        return;
    }
    NSData *encodeData = [value dataUsingEncoding:NSUTF8StringEncoding];
    @synchronized (self) {
        NSString *originPassword = [self itemForKey:key];
        if (originPassword.length > 0) {
            NSMutableDictionary *updateAttributes = [NSMutableDictionary dictionary];
            updateAttributes[(__bridge id)kSecValueData] = encodeData;
            NSMutableDictionary *query = [self keychainQueryWithAccount:key];
            OSStatus statusCode = SecItemUpdate((__bridge CFDictionaryRef)query,(__bridge CFDictionaryRef)updateAttributes);
            if (statusCode != noErr) {
                [TDOSLog logMessage:@"Keychain Update Error" prefix:@"TDCore" type:TDLogTypeError asynchronous:NO];
            }
        } else {
            NSMutableDictionary *attributes = [self keychainQueryWithAccount:key];
            attributes[(__bridge id)kSecValueData] = encodeData;
            OSStatus statusCode = SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
            if (statusCode != noErr) {
                [TDOSLog logMessage:@"Keychain Add Error" prefix:@"TDCore" type:TDLogTypeError asynchronous:NO];
            }
        }
    }
}

+ (void)oldSaveItem:(nonnull NSString *)value forKey:(nonnull NSString *)key {
    if (!key || !value) {
        return;
    }
    NSData *encodeData = [value dataUsingEncoding:NSUTF8StringEncoding];
    @synchronized (self) {
        NSString *originPassword = [self oldItemForKey:key];
        if (originPassword.length > 0) {
            NSMutableDictionary *updateAttributes = [NSMutableDictionary dictionary];
            updateAttributes[(__bridge id)kSecValueData] = encodeData;
            NSMutableDictionary *query = [self oldKeychainQueryWithAccount:key];
            OSStatus statusCode = SecItemUpdate((__bridge CFDictionaryRef)query,(__bridge CFDictionaryRef)updateAttributes);
            if (statusCode != noErr) {
                [TDOSLog logMessage:@"Keychain Update Error" prefix:@"TDCore" type:TDLogTypeError asynchronous:NO];
            }
        } else {
            NSMutableDictionary *attributes = [self oldKeychainQueryWithAccount:key];
            attributes[(__bridge id)kSecValueData] = encodeData;
            OSStatus statusCode = SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
            if (statusCode != noErr) {
                [TDOSLog logMessage:@"Keychain Add Error" prefix:@"TDCore" type:TDLogTypeError asynchronous:NO];
            }
        }
    }
}

+ (nullable NSString *)itemForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    NSMutableDictionary *attributes = [self keychainQueryWithAccount:key];
    attributes[(__bridge id)kSecMatchLimit] = (__bridge id)(kSecMatchLimitOne);
    attributes[(__bridge id)kSecReturnData] = (__bridge id)(kCFBooleanTrue);
    NSString *result = nil;
    @synchronized (self) {
        CFTypeRef data = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attributes,(CFTypeRef *)&data);
        if (status == errSecSuccess) {
            NSData *encodeData = [NSData dataWithData:(__bridge NSData *)data];
            if (data) {
                CFRelease(data);
            }
            if (encodeData) {
                result = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return result;
}

+ (nullable NSString *)oldItemForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    NSMutableDictionary *attributes = [self oldKeychainQueryWithAccount:key];
    attributes[(__bridge id)kSecMatchLimit] = (__bridge id)(kSecMatchLimitOne);
    attributes[(__bridge id)kSecReturnData] = (__bridge id)(kCFBooleanTrue);
    NSString *result = nil;
    @synchronized (self) {
        CFTypeRef data = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)attributes,(CFTypeRef *)&data);
        if (status == errSecSuccess) {
            NSData *encodeData = [NSData dataWithData:(__bridge NSData *)data];
            if (data) {
                CFRelease(data);
            }
            if (encodeData) {
                result = [[NSString alloc] initWithData:encodeData encoding:NSUTF8StringEncoding];
            }
        }
    }
    return result;
}

+ (BOOL)deleteItemWithKey:(nonnull NSString *)key {
    if (!key) {
        return NO;
    }
    NSMutableDictionary *query = [self keychainQueryWithAccount:key];
    BOOL result = NO;
    @synchronized (self) {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        result = (status == errSecSuccess);
    }
    return result;
}

+ (NSMutableDictionary *)keychainQueryWithAccount:(NSString *)account {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = TDKeychainService;
    query[(__bridge id)kSecAttrAccount] = account;
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    return query;
}

+ (NSMutableDictionary *)oldKeychainQueryWithAccount:(NSString *)account {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrService] = TDKeychainService;
    query[(__bridge id)kSecAttrAccount] = account;
    return query;
}

@end
