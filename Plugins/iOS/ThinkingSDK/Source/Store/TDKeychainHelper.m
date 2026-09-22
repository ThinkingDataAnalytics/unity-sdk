#import "TDKeychainHelper.h"

#if __has_include(<ThinkingDataCore/TDKeychainManager.h>)
#import <ThinkingDataCore/TDKeychainManager.h>
#else
#import "TDKeychainManager.h"
#endif

static NSString * const TDInstallTimesOld = @"com.thinkingddata.analytics.installtimes";
static NSString * const TDInstallTimesNew = @"com.thinkingddata.analytics.installtimes_1";

@interface TDKeychainHelper ()

@end

@implementation TDKeychainHelper

+ (void)saveInstallTimes:(NSString *)string {
    [TDKeychainManager saveItem:string forKey:TDInstallTimesNew];
    
    // Compatibility handles the case of jumping back and forth between old and new SDK versions
    [TDKeychainManager oldSaveItem:string forKey:TDInstallTimesOld];
}

+ (NSString *)readInstallTimes {
    NSString *data = [TDKeychainManager itemForKey:TDInstallTimesNew];
    if (data == nil) {
        data = [TDKeychainManager oldItemForKey:TDInstallTimesOld];
        if (data) {
            [TDKeychainManager saveItem:data forKey:TDInstallTimesNew];
        }
    }
    return data;
}

@end
