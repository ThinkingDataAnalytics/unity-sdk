//
//  TATrackFirstEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDTrackFirstEvent.h"
#import "TDDeviceInfo.h"

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
    
    dict[@"#first_check_id"] = self.firstCheckId ?: [TDDeviceInfo sharedManager].deviceId;
    
    return dict;
}

@end
