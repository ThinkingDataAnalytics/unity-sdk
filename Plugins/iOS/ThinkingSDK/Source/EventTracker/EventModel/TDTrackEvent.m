//
//  TATrackEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDTrackEvent.h"
#import "TDPresetProperties.h"

#if __has_include(<ThinkingDataCore/NSDate+TDCore.h>)
#import <ThinkingDataCore/NSDate+TDCore.h>
#else
#import "NSDate+TDCore.h"
#endif

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif

#if __has_include(<ThinkingDataCore/TDCorePresetDisableConfig.h>)
#import <ThinkingDataCore/TDCorePresetDisableConfig.h>
#else
#import "TDCorePresetDisableConfig.h"
#endif

@implementation TDTrackEvent

- (instancetype)initWithName:(NSString *)eventName {
    if (self = [self init]) {
        self.eventName = eventName;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventType = TDEventTypeTrack;
        self.systemUpTime = [TDCoreDeviceInfo bootTime];
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    
    [TDPropertyValidator validateEventOrPropertyName:self.eventName withError:error];
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    dict[@"#event_name"] = self.eventName;
    
    if (![TDCorePresetDisableConfig disableDuration]) {
        if (self.foregroundDuration > 0) {
            self.properties[@"#duration"] = @([NSString stringWithFormat:@"%.3f", self.foregroundDuration].floatValue);
        }
    }
    
    if (![TDCorePresetDisableConfig disableBackgroundDuration]) {
        if (self.backgroundDuration > 0) {
            self.properties[TD_BACKGROUND_DURATION] = @([NSString stringWithFormat:@"%.3f", self.backgroundDuration].floatValue);
        }
    }
    
    self.properties[@"#zone_offset"] = @([self timeZoneOffset]);

    return dict;
}

- (double)timeZoneOffset {
    NSTimeZone *tz = self.timeZone ?: [NSTimeZone localTimeZone];
    return [[NSDate date] td_timeZoneOffset:tz];
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TDPropertyValidator validateNormalTrackEventPropertyKey:key value:value error:error];
}

@end
