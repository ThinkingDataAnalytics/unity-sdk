//
//  TDLogMessage.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/1/22.
//

#import <Foundation/Foundation.h>
#import "TDLogConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDLogMessage : NSObject
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) TDLogType type;

- (TDLogMessage *)initWithMessage:(NSString *)message prefix:(nullable NSString *)prefix type:(TDLogType)type;

@end

NS_ASSUME_NONNULL_END
