//
//  TDWeakProxy.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/15.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDWeakProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;


@end

NS_ASSUME_NONNULL_END
