//
//  TATrackOverwriteEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDTrackOverwriteEvent.h"

@implementation TDTrackOverwriteEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventType = TDEventTypeTrackOverwrite;
    }
    return self;
}

- (NSMutableDictionary *)jsonObject {
    NSMutableDictionary *dict = [super jsonObject];
    
    dict[@"#event_id"] = self.eventId;
    
    return dict;
}


- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    [super validateWithError:error];
    if (*error) {
        return;
    }
    if (self.eventId.length <= 0) {
        TDLogError(@"property 'eventId' cannot be empty which in OverwriteEvent");
    }
}

@end
