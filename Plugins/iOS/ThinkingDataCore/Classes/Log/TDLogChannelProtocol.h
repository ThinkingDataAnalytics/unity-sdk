//
//  TDLogChannelProtocol.h
//  Pods
//
//  Created by 杨雄 on 2024/1/22.
//

#ifndef TDLogChannelProtocol_h
#define TDLogChannelProtocol_h

#import <Foundation/Foundation.h>
#import "TDLogConstant.h"

@protocol TDLogChannleProtocol <NSObject>

- (void)printMessage:(NSString *)message type:(TDLogType)type;

@end

#endif /* TDLogChannelProtocol_h */
