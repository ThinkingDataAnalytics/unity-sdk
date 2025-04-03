//
//  TDCorePresetProperty.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDCorePresetProperty : NSObject

+ (NSDictionary *)staticProperties;

+ (NSDictionary *)dynamicProperties;

+ (NSDictionary *)allPresetProperties;

@end

NS_ASSUME_NONNULL_END
