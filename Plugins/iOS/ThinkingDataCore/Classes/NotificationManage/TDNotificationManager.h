//
//  TDNotificationManager.h
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDNotificationManager : NSObject

+ (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
