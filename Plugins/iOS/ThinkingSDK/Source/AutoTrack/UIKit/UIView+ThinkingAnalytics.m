//
//  UIView+ThinkingAnalytics.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#import "UIView+ThinkingAnalytics.h"
#import <objc/runtime.h>

static char TD_AUTOTRACK_VIEW_ID;
static char TD_AUTOTRACK_VIEW_ID_APPID;
static char TD_AUTOTRACK_VIEW_IGNORE;
static char TD_AUTOTRACK_VIEW_IGNORE_APPID;
static char TD_AUTOTRACK_VIEW_PROPERTIES;
static char TD_AUTOTRACK_VIEW_PROPERTIES_APPID;
static char TD_AUTOTRACK_VIEW_DELEGATE;

@implementation UIView (ThinkingAnalytics)

- (NSString *)thinkingAnalyticsViewID {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID);
}

- (void)setThinkingAnalyticsViewID:(NSString *)thinkingAnalyticsViewID {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID, thinkingAnalyticsViewID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)thinkingAnalyticsIgnoreView {
    return [objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE) boolValue];
}

- (void)setThinkingAnalyticsIgnoreView:(BOOL)thinkingAnalyticsIgnoreView {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE, [NSNumber numberWithBool:thinkingAnalyticsIgnoreView], OBJC_ASSOCIATION_ASSIGN);
}

- (NSDictionary *)thinkingAnalyticsIgnoreViewWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID);
}

- (void)setThinkingAnalyticsIgnoreViewWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_IGNORE_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewIDWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID);
}

- (void)setThinkingAnalyticsViewIDWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_ID_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewProperties {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES);
}

- (void)setThinkingAnalyticsViewProperties:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)thinkingAnalyticsViewPropertiesWithAppid {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID);
}

- (void)setThinkingAnalyticsViewPropertiesWithAppid:(NSDictionary *)thinkingAnalyticsViewProperties {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_PROPERTIES_APPID, thinkingAnalyticsViewProperties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)thinkingAnalyticsDelegate {
    return objc_getAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE);
}

- (void)setThinkingAnalyticsDelegate:(id)thinkingAnalyticsDelegate {
    objc_setAssociatedObject(self, &TD_AUTOTRACK_VIEW_DELEGATE, thinkingAnalyticsDelegate, OBJC_ASSOCIATION_ASSIGN);
}

@end
