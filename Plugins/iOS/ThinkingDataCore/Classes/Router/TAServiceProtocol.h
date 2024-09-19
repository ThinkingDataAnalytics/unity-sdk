//
//  TAServiceProtocol.h
//  ThinkingSDK.default-Base-Core-Extension-Router-Util-iOS
//
//  Created by wwango on 2022/10/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAServiceProtocol <NSObject>

@optional

+ (BOOL)singleton;

+ (id)shareInstance;

@end

NS_ASSUME_NONNULL_END
