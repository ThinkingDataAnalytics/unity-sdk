//
//  TAPropertyDefaultValidator.m
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import "TDPropertyDefaultValidator.h"
#import "TDPropertyValidator.h"

@implementation TDPropertyDefaultValidator

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError *__autoreleasing  _Nullable *)error {
    [TDPropertyValidator validateBaseEventPropertyKey:key value:value error:error];
}

@end
