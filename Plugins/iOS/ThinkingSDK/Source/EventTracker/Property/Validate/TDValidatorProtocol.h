//
//  TDValidatorProtocol.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#ifndef TDValidatorProtocol_h
#define TDValidatorProtocol_h

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingDataCore/TDLogging.h>)
#import <ThinkingDataCore/TDLogging.h>
#else
#import "TDLogging.h"
#endif

#define TAPropertyError(errorCode, errorMsg) \
    [NSError errorWithDomain:@"ThinkingAnalyticsErrorDomain" \
                        code:errorCode \
                    userInfo:@{NSLocalizedDescriptionKey:errorMsg}] \


@protocol TAPropertyKeyValidating <NSObject>

- (void)ta_validatePropertyKeyWithError:(NSError **)error;

@end

/// The validator protocol of the attribute value, used to verify the attribute value
@protocol TDPropertyValueValidating <NSObject>

- (void)ta_validatePropertyValueWithError:(NSError **)error;

@end

/// The validator protocol of event properties, used to verify the key-value of a certain property
@protocol TDEventPropertyValidating <NSObject>

- (void)ta_validateKey:(NSString *)key value:(id)value error:(NSError **)error;

@end

#endif /* TDValidatorProtocol_h */
