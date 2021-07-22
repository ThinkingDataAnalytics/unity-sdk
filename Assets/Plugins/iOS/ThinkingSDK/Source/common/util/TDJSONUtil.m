#import "TDJSONUtil.h"
#import "TDLogging.h"

@implementation TDJSONUtil

+ (NSString *)JSONStringForObject:(id)obj {
    NSData *data = [self JSONSerializeForObject:obj];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSData *)JSONSerializeForObject:(id)object {
    
    id obj = [TDJSONUtil JSONSerializableObjectForObject:object];
    NSData *data = nil;
    
    if ([NSJSONSerialization isValidJSONObject:obj]) {
        data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:NULL];
    } else {
        TDLogError(@"Invalid json: %@", obj);
    }
    
    return data;
}

+ (id)JSONSerializableObjectForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if ([object stringValue] && [[object stringValue] rangeOfString:@"."].location != NSNotFound) {
            return [NSDecimalNumber decimalNumberWithDecimal:((NSNumber *)object).decimalValue];
        }
        return object;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray<id> *array = [[NSMutableArray alloc] init];
        for (id obj in (NSArray *)object) {
            id convertedObj = [self JSONSerializableObjectForObject:obj];
            [self array:array addObject:convertedObj];
        }
        return array;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, id> *dictionary = [[NSMutableDictionary alloc] init];
        [(NSDictionary<id, id> *)object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *dictionaryStop) {
            [self dictionary:dictionary
                   setObject:[self JSONSerializableObjectForObject:obj]
                      forKey:key];
        }];
        return dictionary;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray<id> *array = [[NSMutableArray alloc] init];
        for (id obj in (NSArray *)object) {
            id convertedObj = [self JSONSerializableObjectForObject:obj];
            [self array:array addObject:convertedObj];
        }
        object = array;
    }
    
    NSString *s = [object description];
    TDLogError(@"%@ warning: property values should be valid json types. got: %@. coercing to: %@", self, [object class], s);
    return s;
}

+ (void)array:(NSMutableArray *)array addObject:(id)object {
    if (object) {
        [array addObject:object];
    }
}

+ (void)dictionary:(NSMutableDictionary<NSString *, id> *)dictionary setObject:(id)object forKey:(id<NSCopying>)key {
    if (object && key) {
        dictionary[key] = object;
    }
}

@end
