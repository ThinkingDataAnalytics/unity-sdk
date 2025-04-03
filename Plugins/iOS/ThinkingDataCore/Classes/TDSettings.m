//
//  TDSettings.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/21.
//

#import "TDSettings.h"
#import "NSObject+TDCore.h"

@implementation TDSettings

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self init]) {
        self.appId = [dict[@"appId"] td_string];
        self.serverUrl = [dict[@"serverUrl"] td_string];
        NSNumber *timezoneOffset = [dict[@"defaultTimeZone"] td_number];
        if (timezoneOffset) {
            self.defaultTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:timezoneOffset.doubleValue * 3600];
        }
        self.enableLog = [dict[@"enableLog"] td_number].boolValue;
        self.enableAutoCalibrated = [dict[@"enableAutoCalibrated"] td_number].boolValue;
        self.enableAutoPush = [dict[@"enableAutoPush"] td_number].boolValue;
        self.encryptKey = [dict[@"encryptKey"] td_string];
        self.encryptVersion = [dict[@"encryptVersion"] td_number].integerValue;
        self.mode = [dict[@"mode"] td_number].integerValue;
        
        NSDictionary *rccFetchParams = dict[@"rccFetchParams"];
        if ([rccFetchParams isKindOfClass:NSDictionary.class]) {
            self.rccFetchParams = rccFetchParams;
        }
    }
    return self;
}

@end
