//
//  TDFPSMonitor.h
//  SSAPMSDK
//
//  Created by wwango on 2021/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDFPSMonitor : NSObject

@property (nonatomic, assign, getter=isEnable) BOOL enable;

- (NSNumber *)getPFS;

@end

NS_ASSUME_NONNULL_END
