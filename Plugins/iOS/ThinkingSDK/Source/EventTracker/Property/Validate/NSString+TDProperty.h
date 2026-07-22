//
//  NSString+TDProperty.h
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import <Foundation/Foundation.h>
#import "TDValidatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TAProperty) <TAPropertyKeyValidating, TDPropertyValueValidating>

@end

NS_ASSUME_NONNULL_END
