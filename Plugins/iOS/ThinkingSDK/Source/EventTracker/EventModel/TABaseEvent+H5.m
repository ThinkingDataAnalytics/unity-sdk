//
//  TABaseEvent+H5.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TABaseEvent+H5.h"
#import <objc/runtime.h>

static char TA_EVENT_H5_TIME_STRING;
static char TA_EVENT_H5_ZONE_OFF_SET;

@implementation TABaseEvent (H5)

- (NSString *)h5TimeString {
    return objc_getAssociatedObject(self, &TA_EVENT_H5_TIME_STRING);
}

- (void)setH5TimeString:(NSString *)h5TimeString {
    objc_setAssociatedObject(self, &TA_EVENT_H5_TIME_STRING, h5TimeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)h5ZoneOffSet {
    return objc_getAssociatedObject(self, &TA_EVENT_H5_ZONE_OFF_SET);
}

- (void)setH5ZoneOffSet:(NSNumber *)h5ZoneOffSet {
    objc_setAssociatedObject(self, &TA_EVENT_H5_ZONE_OFF_SET, h5ZoneOffSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
