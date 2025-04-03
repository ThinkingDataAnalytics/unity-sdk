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

/// app bundle id
@property (nonatomic, copy, readonly) NSString *bundle_id;

/// Mobile phone SIM card operator information. The value is null after ios 16
@property (nonatomic, copy, readonly) NSString *carrier;

/// Device id
@property (nonatomic, copy, readonly) NSString *device_id;

/// Device model
@property (nonatomic, copy, readonly) NSString *device_model;

/// Device manufacture
@property (nonatomic, copy, readonly) NSString *manufacturer;

/// Network type
@property (nonatomic, copy, readonly) NSString *network_type;

/// Operating system name
@property (nonatomic, copy, readonly) NSString *os;

/// Operating system version
@property (nonatomic, copy, readonly) NSString *os_version;

/// screen height
@property (nonatomic, strong, readonly) NSNumber *screen_height;

/// screen width
@property (nonatomic, strong, readonly) NSNumber *screen_width;

/// Mobile phone system language
@property (nonatomic, copy, readonly) NSString *system_language;

/// Time zone offset
@property (nonatomic, copy, readonly) NSNumber *zone_offset;

/// App version
@property (nonatomic, copy, readonly) NSString *appVersion;

/// App install time
@property (nonatomic, copy, readonly) NSString *install_time;

/// Is it a simulator
@property (nonatomic, strong, readonly) NSNumber *isSimulator;

/// Available memory and total memory
@property (nonatomic, copy, readonly) NSString *ram;

/// Available disk and total disk
@property (nonatomic, copy, readonly) NSString *disk;

/// Frame rate
@property (nonatomic, strong, readonly) NSNumber *fps;

/// Device type
@property (nonatomic, copy, readonly) NSString *deviceType;

/**
 * The key of the returned event preset property starts with "#", and it is not recommended to use it directly as the property of the event
 */
- (NSDictionary *)toEventPresetProperties;

@end

NS_ASSUME_NONNULL_END
