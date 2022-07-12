//
//  TDPublicConfig.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDPublicConfig : NSObject

@property(copy,nonatomic) NSArray* controllers;
@property(copy,nonatomic) NSString* version;
+ (NSArray*)controllers;
+ (NSString*)version;

@end

NS_ASSUME_NONNULL_END
