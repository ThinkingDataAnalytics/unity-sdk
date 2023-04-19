//
//  NSString+TAProperty.h
//  Adjust
//
//  Created by Yangxiongon 2022/7/1.
//

#import <Foundation/Foundation.h>
#import "TAValidatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSString (TAProperty) <TAPropertyKeyValidating, TAPropertyValueValidating>

@end

NS_ASSUME_NONNULL_END
