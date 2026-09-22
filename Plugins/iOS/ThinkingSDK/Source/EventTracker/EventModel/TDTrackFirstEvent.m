//
//  TATrackFirstEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDTrackFirstEvent.h"

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif


@implementation TDTrackFirstEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventType = TDEventTypeTrackFirst;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    [super validateWithError:error];
    if (*error) {
        return;
    }
    if (self.firstCheckId.length <= 0) {
        NSString *errorMsg = @"property 'firstCheckId' cannot be empty which in FirstEvent";
        *error = TAPropertyError(100010, errorMsg);
        return;
    }
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    dict[@"#first_check_id"] = self.firstCheckId ?: [TDCoreDeviceInfo deviceId];
    
    return dict;
}

@end
