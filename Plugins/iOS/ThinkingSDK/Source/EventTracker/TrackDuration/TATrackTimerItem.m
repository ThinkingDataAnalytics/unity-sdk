//
//  TATrackTimerItem.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/1.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "TATrackTimerItem.h"

@implementation TATrackTimerItem

-(NSString *)description {
    return [NSString stringWithFormat:@"beginTime: %lf, foregroundDuration: %lf, enterBackgroundTime: %lf, backgroundDuration: %lf", _beginTime, _foregroundDuration, _enterBackgroundTime, _backgroundDuration];;
}

@end
