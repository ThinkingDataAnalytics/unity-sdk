#import "TDJSONUtil.h"

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
    @try {
        if ([NSJSONSerialization isValidJSONObject:obj]) {
            NSError *error = nil;
            data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingFragmentsAllowed error:&error];
            if (error != nil) {
                return nil;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    return data;
}

+ (nullable id)jsonForData:(NSData *)data {
    if (![data isKindOfClass:NSData.class]) {
        return nil;
    }
    @try {
        NSError *jsonSeralizeError = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonSeralizeError];
        if (jsonSeralizeError == nil) {
            return json;
        }
    } @catch (NSException *exception) {
        //
    }
    return nil;
}

+ (id)JSONSerializableObjectForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object isKindOfClass:[NSNumber class]]) {

        if ([object stringValue] && [[object stringValue] rangeOfString:@"."].location != NSNotFound) {
            return [NSDecimalNumber decimalNumberWithDecimal:((NSNumber *)object).decimalValue];
        }
        if ([object stringValue] && ([[object stringValue] rangeOfString:@"e"].location != NSNotFound ||
                                     [[object stringValue] rangeOfString:@"E"].location != NSNotFound )) {
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

+ (nullable NSMutableDictionary *)formatDateWithFormatter:(nonnull NSDateFormatter *)dateFormatter dict:(NSDictionary *)dict {
    if (![dict isKindOfClass:NSDictionary.class] || ![dateFormatter isKindOfClass:NSDateFormatter.class]) {
        return nil;
    }
    NSMutableDictionary *mutableDict = nil;
    if ([dict isKindOfClass:NSMutableDictionary.class]) {
        mutableDict = (NSMutableDictionary *)dict;
    } else {
        mutableDict = [dict mutableCopy];
    }
    
    NSArray<NSString *> *keys = mutableDict.allKeys;
    for (NSString *key in keys) {
        id value = dict[key];
        
        // 处理字典
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *newDict = [self formatDateWithFormatter:dateFormatter dict:value];
            mutableDict[key] = newDict;
        }
        // 处理数组
        else if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *newArray = [self formatArrayWithFormatter:dateFormatter array:value];
            mutableDict[key] = newArray;
        }
        // 处理集合
        else if ([value isKindOfClass:[NSSet class]]) {
            NSSet *setData = value;
            NSArray *newArray = [self formatArrayWithFormatter:dateFormatter array:setData.allObjects];
            mutableDict[key] = newArray;
        }
        // 处理日期
        else if ([value isKindOfClass:[NSDate class]]) {
            NSString *newValue = [dateFormatter stringFromDate:(NSDate *)value];
            mutableDict[key] = newValue;
        }

    }
    return mutableDict;
}


+ (NSMutableArray *)formatArrayWithFormatter:(nonnull NSDateFormatter *)dateFormatter array:(NSArray *)array {
    NSMutableArray *mutableArray = nil;
    if ([array isKindOfClass:[NSMutableArray class]]) {
        mutableArray = (NSMutableArray *)array;
    } else {
        mutableArray = [array mutableCopy];
    }

    for (int i = 0; i < mutableArray.count; i++) {
        id value = mutableArray[i];
        if ([value isKindOfClass:[NSDate class]]) {
            NSString *newValue = [dateFormatter stringFromDate:(NSDate *)value];
            mutableArray[i] = newValue;
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *newDict = [self formatDateWithFormatter:dateFormatter dict:value];
            mutableArray[i] = newDict;
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *newArray = [self formatArrayWithFormatter:dateFormatter array:value];
            mutableArray[i] = newArray;
        } else if ([value isKindOfClass:[NSSet class]]) {
            NSSet *setData = value;
            NSArray *newArray = [self formatArrayWithFormatter:dateFormatter array:setData.allObjects];
            mutableArray[i] = newArray;
        }
    }
    return mutableArray;
}

@end
