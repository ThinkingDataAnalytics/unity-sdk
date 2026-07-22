//
//  TAUserEvent.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/12.
//

#import "TDUserEvent.h"

@implementation TDUserEvent

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TDPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

//MARK: - Setter & Getter

@end
