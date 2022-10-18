//
//  TDPresetProperties.h
//  ThinkingSDK
//
//  Created by huangdiao on 2021/5/25.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDPresetProperties : NSObject

@property (nonatomic, copy, readonly) NSString *bundle_id;
@property (nonatomic, copy, readonly) NSString *carrier;
@property (nonatomic, copy, readonly) NSString *device_id;
@property (nonatomic, copy, readonly) NSString *device_model;
@property (nonatomic, copy, readonly) NSString *manufacturer;
@property (nonatomic, copy, readonly) NSString *network_type;
@property (nonatomic, copy, readonly) NSString *os;
@property (nonatomic, copy, readonly) NSString *os_version;
@property (nonatomic, copy, readonly) NSNumber *screen_height;
@property (nonatomic, copy, readonly) NSNumber *screen_width;
@property (nonatomic, copy, readonly) NSString *system_language;
@property (nonatomic, copy, readonly) NSNumber *zone_offset;

/**
 * 返回事件预置属性的Key以"#"开头，不建直接作为事件的Property使用
 */
- (NSDictionary *)toEventPresetProperties;

@end

NS_ASSUME_NONNULL_END
