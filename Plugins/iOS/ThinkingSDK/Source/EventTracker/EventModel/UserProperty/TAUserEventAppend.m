//
//  TAUserEventAppend.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TAUserEventAppend.h"

@implementation TAUserEventAppend

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TAEventTypeUserAppend;
    }
    return self;
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [super ta_validateKey:key value:value error:error];
    if (*error) {
        return;
    }
    if (![value isKindOfClass:NSArray.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSArray. got: %@ %@. ", [value class], value];
        *error = TAPropertyError(10009, errMsg);
    }
}

@end
