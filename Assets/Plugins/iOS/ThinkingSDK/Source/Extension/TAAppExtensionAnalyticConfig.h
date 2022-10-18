//
//  TAAppExtensionAnalyticConfig.h
//  Pods
//
//  Created by 杨雄 on 2022/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAAppExtensionAnalyticConfig : NSObject
/// 事件采集对象的唯一标识
@property (nonatomic, copy) NSString *instanceName;
/// app group identifier
@property (nonatomic, copy) NSString *appGroupId;

@end

NS_ASSUME_NONNULL_END
