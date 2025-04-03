//
//  TDCoreLog.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define TDCORELOG(format, ...) [TDCoreLog printLog:(format), ##__VA_ARGS__]

@interface TDCoreLog : NSObject

+ (void)enableLog:(BOOL)enable;

+ (void)printLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end

NS_ASSUME_NONNULL_END
