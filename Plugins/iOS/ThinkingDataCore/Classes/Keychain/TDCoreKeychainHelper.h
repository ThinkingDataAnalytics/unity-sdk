//
//  TDCoreKeychainHelper.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCoreKeychainHelper : NSObject

+ (void)saveDeviceId:(NSString *)string;

+ (NSString *)readDeviceId;

@end

NS_ASSUME_NONNULL_END
