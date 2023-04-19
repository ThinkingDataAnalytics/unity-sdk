//
//  TAAppExtensionAnalyticConfig.h
//  Pods
//
//  Created by Yangxiongon 2022/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAAppExtensionAnalyticConfig : NSObject
/// instance tag
@property (nonatomic, copy) NSString *instanceName;
/// app group identifier
@property (nonatomic, copy) NSString *appGroupId;

@end

NS_ASSUME_NONNULL_END
