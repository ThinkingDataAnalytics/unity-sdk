//
//  TDCheck.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/10.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define TD_CHECK_NIL(_object) (_object == nil || [_object isKindOfClass:[NSNull class]])

#define TD_CHECK_CLASS(_object, _class) (!TD_CHECK_NIL(_object) && [_object isKindOfClass:[_class class]])

#define TD_CHECK_CLASS_NSString(_object) TD_CHECK_CLASS(_object, [NSString class])
#define TD_CHECK_CLASS_NSNumber(_object) TD_CHECK_CLASS(_object, [NSNumber class])
#define TD_CHECK_CLASS_NSArray(_object) TD_CHECK_CLASS(_object, [NSArray class])
#define TD_CHECK_CLASS_NSData(_object) TD_CHECK_CLASS(_object, [NSData class])
#define TD_CHECK_CLASS_NSDate(_object) TD_CHECK_CLASS(_object, [NSDate class])
#define TD_CHECK_CLASS_NSDictionary(_object) TD_CHECK_CLASS(_object, [NSDictionary class])

#define TD_Valid_NSString(_object) (TD_CHECK_CLASS_NSString(_object) && (_object.length > 0))
#define TD_Valid_NSArray(_object) (TD_CHECK_CLASS_NSArray(_object) && (_object.count > 0))
#define TD_Valid_NSData(_object) (TD_CHECK_CLASS_NSData(_object) && (_object.length > 0))
#define TD_Valid_NSDictionary(_object) (TD_CHECK_CLASS_NSDictionary(_object) && (_object.allKeys.count > 0))

@interface TDCheck : NSObject

+ (NSDictionary *)td_checkToJSONObjectRecursive:(NSDictionary *)properties timeFormatter:(NSDateFormatter *)timeFormatter;

@end


NS_ASSUME_NONNULL_END
