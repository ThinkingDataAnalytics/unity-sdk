//
//  TAPresetPropertyPlugin.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TAPresetPropertyPlugin.h"
#import "TDPresetProperties.h"
#import "TDPresetProperties+TDDisProperties.h"
#import "TDDeviceInfo.h"
#import "TAReachability.h"
#import "NSDate+TAFormat.h"

@interface TAPresetPropertyPlugin ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *properties;

@end

@implementation TAPresetPropertyPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    if (![TDPresetProperties disableAppVersion]) {
        self.properties[@"#app_version"] = [TDDeviceInfo sharedManager].appVersion;
    }
    if (![TDPresetProperties disableBundleId]) {
        self.properties[@"#bundle_id"] = [TDDeviceInfo bundleId];
    }
        
    if (![TDPresetProperties disableInstallTime]) {
        NSString *timeString = [[TDDeviceInfo td_getInstallTime] ta_formatWithTimeZone:self.defaultTimeZone formatString: @"yyyy-MM-dd HH:mm:ss.SSS"];
        if (timeString && [timeString isKindOfClass:[NSString class]] && timeString.length){
            self.properties[@"#install_time"] = timeString;
        }
    }
}

- (void)asyncGetPropertyCompletion:(TAPropertyPluginCompletion)completion {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    
    [mutableDict addEntriesFromDictionary:[[TDDeviceInfo sharedManager] getAutomaticData]];
    
    if (![TDPresetProperties disableNetworkType]) {
        mutableDict[@"#network_type"] = [[TAReachability shareInstance] networkState];
    }
    
    if (completion) {
        completion(mutableDict);
    }
}

@end
