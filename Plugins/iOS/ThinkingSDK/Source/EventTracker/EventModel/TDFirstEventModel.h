
#if __has_include(<ThinkingSDK/TDEventModel.h>)
#import <ThinkingSDK/TDEventModel.h>
#else
#import "TDEventModel.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface TDFirstEventModel : TDEventModel

- (instancetype)initWithEventName:(NSString * _Nullable)eventName;

- (instancetype)initWithEventName:(NSString * _Nullable)eventName firstCheckID:(NSString *)firstCheckID;

@end

NS_ASSUME_NONNULL_END
