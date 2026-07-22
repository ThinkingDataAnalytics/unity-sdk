//
//  TATrackTimerItem.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDTrackTimerItem : NSObject
/// The moment when the event starts to be recorded (the total time the device has been running)
@property (nonatomic, assign) NSTimeInterval beginTime;
/// Accumulated time in the foreground
@property (nonatomic, assign) NSTimeInterval foregroundDuration;
/// The time the event entered the background (total time the device has been running)
@property (nonatomic, assign) NSTimeInterval enterBackgroundTime;
/// accumulated time in the background
@property (nonatomic, assign) NSTimeInterval backgroundDuration;

@end

NS_ASSUME_NONNULL_END
