
#if __has_include(<ThinkingSDK/TDEventModel.h>)
#import <ThinkingSDK/TDEventModel.h>
#else
#import "TDEventModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDEditableEventModel : TDEventModel

- (instancetype)initWithEventName:(NSString *)eventName eventID:(NSString *)eventID;

@end

@interface TDUpdateEventModel : TDEditableEventModel

@end

@interface TDOverwriteEventModel : TDEditableEventModel

@end

NS_ASSUME_NONNULL_END
