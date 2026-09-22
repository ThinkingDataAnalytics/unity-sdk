//
//  TDAppLifeCycle.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// APP life cycle
typedef NS_ENUM(NSUInteger, TDAppLifeCycleState) {
    TDAppLifeCycleStateInit = 1, // init status
    TDAppLifeCycleStateBackgroundStart,
    TDAppLifeCycleStateStart,
    TDAppLifeCycleStateEnd,
    TDAppLifeCycleStateTerminate,
};

/// When the life cycle status is about to change, this notification will be sent
/// object: The object is the current life cycle object
/// userInfo: Contains two keys kTDAppLifeCycleNewStateKey and kTDAppLifeCycleOldStateKey
extern NSNotificationName const kTDAppLifeCycleStateWillChangeNotification;

/// When the life cycle status changes, this notification will be sent
/// object: The object is the current lifecycle object
/// userInfo: Contains two keys kTDAppLifeCycleNewStateKey and kTDAppLifeCycleOldStateKey
extern NSNotificationName const kTDAppLifeCycleStateDidChangeNotification;

/// In the status change notification, get the new status
extern NSString * const kTDAppLifeCycleNewStateKey;

/// In the status change notification, get the status before the change
extern NSString * const kTDAppLifeCycleOldStateKey;

@interface TDAppLifeCycle : NSObject

@property (nonatomic, assign, readonly) TDAppLifeCycleState state;

+ (void)startMonitor;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
