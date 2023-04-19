//
//  TAPropertyDefaultValidator.m
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TAPropertyDefaultValidator.h"
#import "TAPropertyValidator.h"

@implementation TAPropertyDefaultValidator

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TAPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

@end
