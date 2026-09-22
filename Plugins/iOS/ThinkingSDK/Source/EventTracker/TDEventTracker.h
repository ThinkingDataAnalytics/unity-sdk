//
//  TAEventTracker.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingSDK/TDConstant.h>)
#import <ThinkingSDK/TDConstant.h>
#else
#import "TDConstant.h"
#endif

#import "TDSecurityPolicy.h"
#import "ThinkingAnalyticsSDKPrivate.h"

NS_ASSUME_NONNULL_BEGIN

@class TDEventTracker;

@interface TDEventTracker : NSObject

+ (dispatch_queue_t)td_networkQueue;

- (instancetype)initWithQueue:(dispatch_queue_t)queue instanceToken:(NSString *)instanceToken;

- (void)flush;

- (void)track:(NSDictionary *)event immediately:(BOOL)immediately saveOnly:(BOOL)isSaveOnly;

- (void)trackDebugEvent:(NSDictionary *)event;

- (NSInteger)saveEventsData:(NSDictionary *)data;

- (void)_asyncWithCompletion:(void(^)(void))completion;

- (void)syncSendAllData;

#pragma mark - UNAVAILABLE
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
