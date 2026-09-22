#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDJSONUtil : NSObject

+ (NSString *)JSONStringForObject:(id)object;

+ (NSData *)JSONSerializeForObject:(id)object;

+ (nullable id)jsonForData:(nonnull NSData *)data;

+ (nullable NSMutableDictionary *)formatDateWithFormatter:(nonnull NSDateFormatter *)dateFormatter dict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
