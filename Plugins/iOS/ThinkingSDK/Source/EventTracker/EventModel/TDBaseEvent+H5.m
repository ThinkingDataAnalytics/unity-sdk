//
//  TDBaseEvent+H5.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/19.
//

#import "TDBaseEvent+H5.h"
#import <objc/runtime.h>

@implementation TDBaseEvent (H5)

- (NSString *)h5TimeString {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setH5TimeString:(NSString *)h5TimeString {
    objc_setAssociatedObject(self, @selector(h5TimeString), h5TimeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)h5ZoneOffSet {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setH5ZoneOffSet:(NSNumber *)h5ZoneOffSet {
    objc_setAssociatedObject(self, @selector(h5ZoneOffSet), h5ZoneOffSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
