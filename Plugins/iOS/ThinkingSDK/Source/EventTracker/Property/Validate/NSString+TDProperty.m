//
//  NSString+TDProperty.m
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import "NSString+TDProperty.h"


static NSInteger kTAPropertyNameMaxLength = 50;

@implementation NSString (TAProperty)

- (void)ta_validatePropertyKeyWithError:(NSError *__autoreleasing  _Nullable *)error {
    if (self.length == 0) {
        NSString *errorMsg = @"Property key or Event name is empty";
        TDLogError(errorMsg);
        *error = TAPropertyError(10003, errorMsg);
        return;
    }

    if (self.length > kTAPropertyNameMaxLength) {
        NSString *errorMsg = [NSString stringWithFormat:@"Property key or Event name %@'s length is longer than %ld", self, kTAPropertyNameMaxLength];
        TDLogError(errorMsg);
        *error = TAPropertyError(10006, errorMsg);
        return;
    }
    *error = nil;
}

- (void)ta_validatePropertyValueWithError:(NSError *__autoreleasing  _Nullable *)error {
    
}

@end
