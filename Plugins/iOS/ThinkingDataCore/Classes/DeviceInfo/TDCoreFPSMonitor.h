//
//  TDCoreFPSMonitor.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCoreFPSMonitor : NSObject
@property (nonatomic, assign, getter=isEnable) BOOL enable;

- (NSNumber *)getPFS;

@end

NS_ASSUME_NONNULL_END
