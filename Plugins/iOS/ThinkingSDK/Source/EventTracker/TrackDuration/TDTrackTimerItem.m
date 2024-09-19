//
//  TATrackTimerItem.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TDTrackTimerItem.h"

@implementation TDTrackTimerItem

-(NSString *)description {
    return [NSString stringWithFormat:@"beginTime: %lf, foregroundDuration: %lf, enterBackgroundTime: %lf, backgroundDuration: %lf", _beginTime, _foregroundDuration, _enterBackgroundTime, _backgroundDuration];;
}

@end
