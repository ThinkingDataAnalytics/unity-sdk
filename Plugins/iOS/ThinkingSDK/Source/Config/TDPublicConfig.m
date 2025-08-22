//
//  TDPublicConfig.m
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import "TDPublicConfig.h"
static TDPublicConfig* config;

@implementation TDPublicConfig
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [TDPublicConfig new];
    });
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.controllers = @[
        @"UICompatibilityInputViewController",
        @"UIKeyboardCandidateGridCollectionViewController",
        @"UIInputWindowController",
        @"UIApplicationRotationFollowingController",
        @"UIApplicationRotationFollowingControllerNoTouches",
        @"UISystemKeyboardDockController",
        @"UINavigationController",
        @"SFBrowserRemoteViewController",
        @"SFSafariViewController",
        @"UIAlertController",
        @"UIImagePickerController",
        @"PUPhotoPickerHostViewController",
        @"UIViewController",
        @"UITableViewController",
        @"UITabBarController",
        @"_UIRemoteInputViewController",
        @"UIEditingOverlayViewController",
        @"_UIAlertControllerTextFieldViewController",
        @"UIActivityGroupViewController",
        @"_UISFAirDropInstructionsViewController",
        @"_UIActivityGroupListViewController",
        @"_UIShareExtensionRemoteViewController",
        @"SLRemoteComposeViewController",
        @"SLComposeViewController",
        ];
    }
    return self;
}
+ (NSArray*)controllers
{
    return config.controllers;
}
+ (NSString*)version
{
    return @"3.1.0";
}
@end
