//
//  TAPropertyValidator.h
//  Adjust
//
//  Created by Yangxiongon 2022/6/10.
//

#import <Foundation/Foundation.h>
#import "TAValidatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPropertyValidator : NSObject

+ (void)validateEventOrPropertyName:(NSString *)name withError:(NSError **)error;

+ (void)validateBaseEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;

+ (void)validateNormalTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;

+ (void)validateAutoTrackEventPropertyKey:(NSString *)key value:(NSString *)value error:(NSError **)error;


+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties;

+ (NSMutableDictionary *)validateProperties:(NSDictionary *)properties validator:(id<TAEventPropertyValidating>)validator;

@end

NS_ASSUME_NONNULL_END
