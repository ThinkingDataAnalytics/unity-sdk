//
//  UIView+ThinkingAnalytics.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ThinkingAnalytics)

/**
 Set the control element ID
 */
@property (copy,nonatomic) NSString *thinkingAnalyticsViewID;

/**
 Configure the control element ID of APPID
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewIDWithAppid;

/**
 Ignore the click event of a control
 */
@property (nonatomic,assign) BOOL thinkingAnalyticsIgnoreView;

/**
 Configure APPID to ignore the click event of a control
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsIgnoreViewWithAppid;

/**
 Properties of custom control click event
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewProperties;

/**
 Configure the properties of the APPID custom control click event
 */
@property (strong,nonatomic) NSDictionary *thinkingAnalyticsViewPropertiesWithAppid;

/**
 thinkingAnalyticsDelegate
 */
@property (nonatomic, weak, nullable) id thinkingAnalyticsDelegate;

@end

NS_ASSUME_NONNULL_END
