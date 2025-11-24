//
//  TDUserDefaults.h
//  ThinkingDataCore
//
//  Created by 廖德生 on 2024/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDUserDefaults : NSObject

+ (instancetype)standardUserDefaults;

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)setString:(NSString *)value forKey:(NSString *)defaultName;
- (void)removeObjectForKey:(NSString *)defaultName;

- (NSString *)stringForKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (void)synchronize;

@end

NS_ASSUME_NONNULL_END
