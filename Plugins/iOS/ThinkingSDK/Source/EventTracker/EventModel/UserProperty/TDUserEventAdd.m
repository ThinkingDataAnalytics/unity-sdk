//
//  TAUserEventAdd.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDUserEventAdd.h"

@implementation TDUserEventAdd

- (instancetype)init {
    if (self = [super init]) {
        self.eventType = TDEventTypeUserAdd;
    }
    return self;
}

- (void)validateWithError:(NSError *__autoreleasing  _Nullable *)error {
    
}

//MARK: - Delegate

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [super ta_validateKey:key value:value error:error];
    if (*error) {
        return;
    }
    if (![value isKindOfClass:NSNumber.class]) {
        NSString *errMsg = [NSString stringWithFormat:@"Property value must be type NSNumber. got: %@ %@. ", [value class], value];
        *error = TAPropertyError(10008, errMsg);
    }
}

@end
