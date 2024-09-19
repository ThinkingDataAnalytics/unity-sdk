#import "ThinkingAnalyticsSDK.h"
#import "TDColdStartTracker.h"
#import "TDHotStartTracker.h"
#import "TDInstallTracker.h"
#import "TDAutoTrackConst.h"

FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_TITLE;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_URL_PROPERTY;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_REFERRER_URL;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_SCREEN_NAME;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_ELEMENT_ID;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_ELEMENT_TYPE;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_ELEMENT_CONTENT;
FOUNDATION_EXTERN NSString * const TD_EVENT_PROPERTY_ELEMENT_POSITION;

@interface TDAutoTrackManager : NSObject

+ (instancetype)sharedManager;

- (void)trackEventView:(UIView *)view;

- (void)trackEventView:(UIView *)view withIndexPath:(NSIndexPath *)indexPath;

- (void)trackWithAppid:(NSString *)appid withOption:(TDAutoTrackEventType)type;

- (void)viewControlWillAppear:(UIViewController *)controller;

- (void)trackWithEvent:(TDAutoTrackEvent *)event withProperties:(NSDictionary *)properties;

+ (UIViewController *)topPresentedViewController;

#pragma mark - UNAVAILABLE
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

