//
//  TDCheck.h
//  ThinkingSDK
//
//  Created by wwango on 2021/9/10.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 判断对象是否为nil
#define TD_CHECK_NIL(_object) (_object == nil || [_object isKindOfClass:[NSNull class]])

#define TD_CHECK_CLASS(_object, _class) (!TD_CHECK_NIL(_object) && [_object isKindOfClass:[_class class]])

// 判断对象类型
#define TD_CHECK_CLASS_NSString(_object) TD_CHECK_CLASS(_object, [NSString class])
#define TD_CHECK_CLASS_NSNumber(_object) TD_CHECK_CLASS(_object, [NSNumber class])
#define TD_CHECK_CLASS_NSArray(_object) TD_CHECK_CLASS(_object, [NSArray class])
#define TD_CHECK_CLASS_NSData(_object) TD_CHECK_CLASS(_object, [NSData class])
#define TD_CHECK_CLASS_NSDate(_object) TD_CHECK_CLASS(_object, [NSDate class])
#define TD_CHECK_CLASS_NSDictionary(_object) TD_CHECK_CLASS(_object, [NSDictionary class])

// 判断对象是否有值
#define TD_Valid_NSString(_object) (TD_CHECK_CLASS_NSString(_object) && (_object.length > 0))
#define TD_Valid_NSArray(_object) (TD_CHECK_CLASS_NSArray(_object) && (_object.count > 0))
#define TD_Valid_NSData(_object) (TD_CHECK_CLASS_NSData(_object) && (_object.length > 0))
#define TD_Valid_NSDictionary(_object) (TD_CHECK_CLASS_NSDictionary(_object) && (_object.allKeys.count > 0))

@interface TDCheck : NSObject

/// 遍历每个属性（递归）
/// @param properties 需要遍历的字典
/// @param timeFormatter 时间格式
/// @note 支持解析的类型：列表<String> 、 数值 、布尔 、文本 、时间 、 JSON对象 、列表<JSON对象>， 内部会递归，层级别太深!!!!! 不然复杂度会猛烈升高，你懂得。
+ (NSDictionary *)td_checkToJSONObjectRecursive:(NSDictionary *)properties timeFormatter:(NSDateFormatter *)timeFormatter;

@end


NS_ASSUME_NONNULL_END
