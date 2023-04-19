//
//  TAUserEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TAUserEvent.h"

@implementation TAUserEvent

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timeValueType = TAEventTimeValueTypeNone;
    }
    return self;
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TAPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

//MARK: - Setter & Getter

- (void)setTime:(NSDate *)time {
    [super setTime:time];
    
    self.timeValueType = time == nil ? TAEventTimeValueTypeNone : TAEventTimeValueTypeTimeOnly;
}

@end
