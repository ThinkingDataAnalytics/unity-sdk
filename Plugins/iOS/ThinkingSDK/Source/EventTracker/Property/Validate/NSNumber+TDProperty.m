//
//  NSNumber+TDProperty.m
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import "NSNumber+TDProperty.h"

@implementation NSNumber (TAProperty)

- (void)ta_validatePropertyValueWithError:(NSError *__autoreleasing  _Nullable *)error {
    if ([self doubleValue] > 9999999999999.999 || [self doubleValue] < -9999999999999.999) {
        NSString *errorMsg = [NSString stringWithFormat:@"The number value [%@] is invalid.", self];
        TDLogError(errorMsg);
        *error = TAPropertyError(10009, errorMsg);
    }
}

@end
