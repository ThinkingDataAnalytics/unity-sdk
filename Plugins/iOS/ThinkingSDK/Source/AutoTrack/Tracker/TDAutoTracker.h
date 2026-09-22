//
//  TDAutoTracker.h
//  ThinkingSDK
//
//  Created by wwango on 2021/10/13.
//  Copyright © 2021 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThinkingAnalyticsSDK.h"
#import "TDAutoTrackEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface TDAutoTracker : NSObject

@property (atomic, assign) BOOL isOneTime;

@property (atomic, assign) BOOL autoFlush;

@property (atomic, assign) BOOL additionalCondition;

- (void)trackWithInstanceTag:(NSString *)instanceName event:(TDAutoTrackEvent *)event params:(nullable NSDictionary *)params;


@end

NS_ASSUME_NONNULL_END
