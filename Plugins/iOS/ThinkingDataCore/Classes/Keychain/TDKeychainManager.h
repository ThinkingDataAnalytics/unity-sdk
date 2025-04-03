//
//  TDKeychainManager.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDKeychainManager : NSObject
+ (void)saveItem:(nonnull NSString *)value forKey:(nonnull NSString *)key;
+ (void)oldSaveItem:(nonnull NSString *)value forKey:(nonnull NSString *)key;
+ (nullable NSString *)itemForKey:(nonnull NSString *)key;
+ (BOOL)deleteItemWithKey:(nonnull NSString *)key;
+ (nullable NSString *)oldItemForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
