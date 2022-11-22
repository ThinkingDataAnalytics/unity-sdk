//
//  TATrackTimerItem.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TATrackTimerItem : NSObject
/// 事件开始记录的时刻（设备开机运行的总时长）
@property (nonatomic, assign) NSTimeInterval beginTime;
/// 累计在前台的时间
@property (nonatomic, assign) NSTimeInterval foregroundDuration;
/// 事件进入后台的时刻（设备开机运行的总时长）
@property (nonatomic, assign) NSTimeInterval enterBackgroundTime;
/// 累计在后台的时间
@property (nonatomic, assign) NSTimeInterval backgroundDuration;

@end

NS_ASSUME_NONNULL_END
