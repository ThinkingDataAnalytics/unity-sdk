//
//  TDLogConstant.h
//  Pods
//
//  Created by 杨雄 on 2024/1/22.
//

#ifndef TDLogConstant_h
#define TDLogConstant_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TDLogType) {
    TDLogTypeOff = 0,
    TDLogTypeError = 1 << 0,
    TDLogTypeWarning = 1 << 1,
    TDLogTypeInfo = 1 << 2,
    TDLogTypeDebug = 1 << 3,
};

#endif /* TDLogConstant_h */
