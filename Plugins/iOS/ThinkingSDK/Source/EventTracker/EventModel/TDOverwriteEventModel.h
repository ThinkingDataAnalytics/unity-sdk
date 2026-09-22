//
//  TDOverwriteEventModel.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#if __has_include(<ThinkingSDK/TDEventModel.h>)
#import <ThinkingSDK/TDEventModel.h>
#else
#import "TDEventModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDOverwriteEventModel : TDEventModel

- (instancetype)initWithEventName:(NSString *)eventName eventID:(NSString *)eventID;

@end

NS_ASSUME_NONNULL_END
