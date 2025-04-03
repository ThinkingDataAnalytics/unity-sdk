//
//  TDCoreKeychainHelper.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/5/24.
//

#import "TDCoreKeychainHelper.h"
#import "TDKeychainManager.h"

static NSString * const kTDDeviceIDOld = @"com.thinkingddata.analytics.deviceid";
static NSString * const kTDDeviceIDNew = @"com.thinkingddata.analytics.deviceid_1";

@implementation TDCoreKeychainHelper

+ (void)saveDeviceId:(NSString *)string {
    [TDKeychainManager saveItem:string forKey:kTDDeviceIDNew];
    
    // Compatibility handles the case of jumping back and forth between old and new SDK versions
    [TDKeychainManager oldSaveItem:string forKey:kTDDeviceIDOld];
}

+ (NSString *)readDeviceId {
    NSString *data = [TDKeychainManager itemForKey:kTDDeviceIDNew];
    if (data == nil) {
        data = [TDKeychainManager oldItemForKey:kTDDeviceIDOld];
        if (data) {
            [TDKeychainManager saveItem:data forKey:kTDDeviceIDNew];
        }
    }
    return data;
}

@end
