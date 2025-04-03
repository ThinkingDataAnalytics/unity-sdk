#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const VERSION;

@interface TDDeviceInfo : NSObject
@property (nonatomic, copy, readonly) NSString *uniqueId;
@property (nonatomic, assign, readonly) BOOL isFirstOpen;
@property (nonatomic, copy) NSString *libName;
@property (nonatomic, copy) NSString *libVersion;

+ (TDDeviceInfo *)sharedManager;

@end

NS_ASSUME_NONNULL_END
