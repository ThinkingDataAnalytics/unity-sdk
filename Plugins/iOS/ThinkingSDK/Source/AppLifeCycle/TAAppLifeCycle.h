//
//  TAAppLifeCycle.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// APP life cycle
typedef NS_ENUM(NSUInteger, TAAppLifeCycleState) {
    TAAppLifeCycleStateInit = 1, // init status
    TAAppLifeCycleStateBackgroundStart,
    TAAppLifeCycleStateStart,
    TAAppLifeCycleStateEnd,
    TAAppLifeCycleStateTerminate,
};

/// When the life cycle status is about to change, this notification will be sent
/// object: The object is the current life cycle object
/// userInfo: Contains two keys kTAAppLifeCycleNewStateKey and kTAAppLifeCycleOldStateKey
extern NSNotificationName const kTAAppLifeCycleStateWillChangeNotification;

/// When the life cycle status changes, this notification will be sent
/// object: The object is the current lifecycle object
/// userInfo: Contains two keys kTAAppLifeCycleNewStateKey and kTAAppLifeCycleOldStateKey
extern NSNotificationName const kTAAppLifeCycleStateDidChangeNotification;

/// In the status change notification, get the new status
extern NSString * const kTAAppLifeCycleNewStateKey;

/// In the status change notification, get the status before the change
extern NSString * const kTAAppLifeCycleOldStateKey;

@interface TAAppLifeCycle : NSObject

@property (nonatomic, assign, readonly) TAAppLifeCycleState state;

+ (void)startMonitor;

+ (instancetype)shareInstance;

@end

NS_ASSUME_NONNULL_END
