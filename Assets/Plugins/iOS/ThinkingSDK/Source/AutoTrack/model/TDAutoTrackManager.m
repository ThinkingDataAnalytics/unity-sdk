#import "TDAutoTrackManager.h"

#import "TDSwizzler.h"
#import "UIViewController+AutoTrack.h"
#import "NSObject+TDSwizzle.h"
#import "TDJSONUtil.h"
#import "UIApplication+AutoTrack.h"
#import "ThinkingAnalyticsSDKPrivate.h"
#import "TDPublicConfig.h"
#import "TDAppState.h"

#ifndef TD_LOCK
#define TD_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef TD_UNLOCK
#define TD_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

NSString * const TD_EVENT_PROPERTY_TITLE = @"#title";
NSString * const TD_EVENT_PROPERTY_URL_PROPERTY = @"#url";
NSString * const TD_EVENT_PROPERTY_REFERRER_URL = @"#referrer";
NSString * const TD_EVENT_PROPERTY_SCREEN_NAME = @"#screen_name";
NSString * const TD_EVENT_PROPERTY_ELEMENT_ID = @"#element_id";
NSString * const TD_EVENT_PROPERTY_ELEMENT_TYPE = @"#element_type";
NSString * const TD_EVENT_PROPERTY_ELEMENT_CONTENT = @"#element_content";
NSString * const TD_EVENT_PROPERTY_ELEMENT_POSITION = @"#element_position";

@interface TDAutoTrackManager ()

@property (atomic, strong) NSMutableDictionary<NSString *, id> *autoTrackOptions;
@property (nonatomic, strong, nonnull) dispatch_semaphore_t trackOptionLock;
@property (atomic, copy) NSString *referrerViewControllerUrl;

@end


@implementation TDAutoTrackManager

#pragma mark - Public

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static TDAutoTrackManager *instance = nil;
    dispatch_once(&once, ^{
        instance = [[[TDAutoTrackManager class] alloc] init];
        instance.autoTrackOptions = [NSMutableDictionary new];
        instance.trackOptionLock = dispatch_semaphore_create(1);
    });
    return instance;
}

- (void)trackEventView:(UIView *)view {
    [self trackEventView:view withIndexPath:nil];
}

- (void)trackEventView:(UIView *)view withIndexPath:(NSIndexPath *)indexPath {
    if (view.thinkingAnalyticsIgnoreView) {
        return;
    }
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    properties[TD_EVENT_PROPERTY_ELEMENT_ID] = view.thinkingAnalyticsViewID;
    properties[TD_EVENT_PROPERTY_ELEMENT_TYPE] = NSStringFromClass([view class]);
    UIViewController *viewController = [self viewControllerForView:view];
    if (viewController != nil) {
        NSString *screenName = NSStringFromClass([viewController class]);
        properties[TD_EVENT_PROPERTY_SCREEN_NAME] = screenName;
        
        NSString *controllerTitle = [self titleFromViewController:viewController];
        if (controllerTitle) {
            properties[TD_EVENT_PROPERTY_TITLE] = controllerTitle;
        }
    }
    
    NSDictionary *propDict = view.thinkingAnalyticsViewProperties;
    if ([propDict isKindOfClass:[NSDictionary class]]) {
        [properties addEntriesFromDictionary:propDict];
    }
    
    UIView *contentView;
    NSDictionary *propertyWithAppid;
    if (indexPath) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            contentView = [tableView cellForRowAtIndexPath:indexPath];
            if (!contentView) {
                [tableView layoutIfNeeded];
                contentView = [tableView cellForRowAtIndexPath:indexPath];
            }
            properties[TD_EVENT_PROPERTY_ELEMENT_POSITION] = [NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
            
            if ([tableView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([tableView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_tableView:autoTrackPropertiesAtIndexPath:)]) {
                    NSDictionary *dic = [view.thinkingAnalyticsDelegate thinkingAnalytics_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        [properties addEntriesFromDictionary:dic];
                    }
                }
                
                if ([tableView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalyticsWithAppid_tableView:autoTrackPropertiesAtIndexPath:)]) {
                    propertyWithAppid = [view.thinkingAnalyticsDelegate thinkingAnalyticsWithAppid_tableView:tableView autoTrackPropertiesAtIndexPath:indexPath];
                }
            }
        } else if ([view isKindOfClass:[UICollectionView class]]) {
            UICollectionView *collectionView = (UICollectionView *)view;
            contentView = [collectionView cellForItemAtIndexPath:indexPath];
            if (!contentView) {
                [collectionView layoutIfNeeded];
                contentView = [collectionView cellForItemAtIndexPath:indexPath];
            }
            properties[TD_EVENT_PROPERTY_ELEMENT_POSITION] = [NSString stringWithFormat: @"%ld:%ld", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
            
            if ([collectionView.thinkingAnalyticsDelegate conformsToProtocol:@protocol(TDUIViewAutoTrackDelegate)]) {
                if ([collectionView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalytics_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                    NSDictionary *dic = [view.thinkingAnalyticsDelegate thinkingAnalytics_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath];
                    if ([dic isKindOfClass:[NSDictionary class]]) {
                        [properties addEntriesFromDictionary:dic];
                    }
                }
                if ([collectionView.thinkingAnalyticsDelegate respondsToSelector:@selector(thinkingAnalyticsWithAppid_collectionView:autoTrackPropertiesAtIndexPath:)]) {
                    propertyWithAppid = [view.thinkingAnalyticsDelegate thinkingAnalyticsWithAppid_collectionView:collectionView autoTrackPropertiesAtIndexPath:indexPath];
                }
            }
        }
    } else {
        contentView = view;
        properties[TD_EVENT_PROPERTY_ELEMENT_POSITION] = [TDAutoTrackManager getPosition:contentView];
    }
    
    NSString *content = [TDAutoTrackManager getText:contentView];
    if (content.length > 0)
        properties[TD_EVENT_PROPERTY_ELEMENT_CONTENT] = content;
    
    NSDate *trackDate = [NSDate date];
    for (NSString *appid in self.autoTrackOptions) {
        ThinkingAnalyticsAutoTrackEventType type = (ThinkingAnalyticsAutoTrackEventType)[self.autoTrackOptions[appid] integerValue];
        
        if (type & ThinkingAnalyticsEventTypeAppClick) {
            ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
            NSMutableDictionary *trackProperties = [properties mutableCopy];
            if ([instance isViewTypeIgnored:[view class]]) {
                continue;
            }
            NSDictionary *ignoreViews = view.thinkingAnalyticsIgnoreViewWithAppid;
            if (ignoreViews != nil && [[ignoreViews objectForKey:appid] isKindOfClass:[NSNumber class]]) {
                BOOL ignore = [[ignoreViews objectForKey:appid] boolValue];
                if (ignore)
                    continue;
            }
            
            if ([instance isViewControllerIgnored:viewController]) {
                continue;
            }
            
            NSDictionary *viewIDs = view.thinkingAnalyticsViewIDWithAppid;
            if (viewIDs != nil && [viewIDs objectForKey:appid]) {
                trackProperties[TD_EVENT_PROPERTY_ELEMENT_ID] = [viewIDs objectForKey:appid];
            }
            
            NSDictionary *viewProperties = view.thinkingAnalyticsViewPropertiesWithAppid;
            if (viewProperties != nil && [viewProperties objectForKey:appid]) {
                NSDictionary *properties = [viewProperties objectForKey:appid];
                if ([properties isKindOfClass:[NSDictionary class]]) {
                    [trackProperties addEntriesFromDictionary:properties];
                }
            }
            
            if (propertyWithAppid) {
                NSDictionary *autoTrackproperties = [propertyWithAppid objectForKey:appid];
                if ([autoTrackproperties isKindOfClass:[NSDictionary class]]) {
                    [trackProperties addEntriesFromDictionary:autoTrackproperties];
                }
            }
            
            [instance autotrack:TD_APP_CLICK_EVENT properties:trackProperties withTime:trackDate];
        }
    }
}

- (void)trackWithAppid:(NSString *)appid withOption:(ThinkingAnalyticsAutoTrackEventType)type {
    TD_LOCK(self.trackOptionLock);
    self.autoTrackOptions[appid] = @(type);
    TD_UNLOCK(self.trackOptionLock);
    
    if (type & ThinkingAnalyticsEventTypeAppClick || type & ThinkingAnalyticsEventTypeAppViewScreen) {
        [self swizzleVC];
    }
}

- (void)viewControlWillAppear:(UIViewController *)controller {
    [self trackViewController:controller];
}

+ (UIViewController *)topPresentedViewController {
    UIWindow *keyWindow = [self findWindow];
    if (keyWindow != nil && !keyWindow.isKeyWindow) {
        [keyWindow makeKeyWindow];
    }
    
    UIViewController *topController = keyWindow.rootViewController;
    if ([topController isKindOfClass:[UINavigationController class]]) {
        topController = [(UINavigationController *)topController topViewController];
    }
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

#pragma mark - Private

- (BOOL)isAutoTrackEventType:(ThinkingAnalyticsAutoTrackEventType)eventType {
    BOOL isIgnored = YES;
    for (NSString *appid in self.autoTrackOptions) {
        ThinkingAnalyticsAutoTrackEventType type = (ThinkingAnalyticsAutoTrackEventType)[self.autoTrackOptions[appid] integerValue];
        isIgnored = !(type & eventType);
        if (isIgnored == NO)
            break;
    }
    return !isIgnored;
}

- (UIViewController *)viewControllerForView:(UIView *)view {
    UIResponder *responder = view.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            if ([responder isKindOfClass:[UINavigationController class]]) {
                responder = [(UINavigationController *)responder topViewController];
                continue;
            } else if ([responder isKindOfClass:UITabBarController.class]) {
                responder = [(UITabBarController *)responder selectedViewController];
                continue;
            }
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

- (void)trackViewController:(UIViewController *)controller {
    if (![self shouldTrackViewContrller:[controller class]]) {
        return;
    }
    
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setValue:NSStringFromClass([controller class]) forKey:TD_EVENT_PROPERTY_SCREEN_NAME];
    
    NSString *controllerTitle = [self titleFromViewController:controller];
    if (controllerTitle) {
        [properties setValue:controllerTitle forKey:TD_EVENT_PROPERTY_TITLE];
    }
    
    NSDictionary *autoTrackerAppidDic;
    if ([controller conformsToProtocol:@protocol(TDAutoTracker)]) {
        UIViewController<TDAutoTracker> *autoTrackerController = (UIViewController<TDAutoTracker> *)controller;
        NSDictionary *autoTrackerDic;
        if ([controller respondsToSelector:@selector(getTrackPropertiesWithAppid)])
            autoTrackerAppidDic = [autoTrackerController getTrackPropertiesWithAppid];
        if ([controller respondsToSelector:@selector(getTrackProperties)])
            autoTrackerDic = [autoTrackerController getTrackProperties];
        
        if ([autoTrackerDic isKindOfClass:[NSDictionary class]]) {
            [properties addEntriesFromDictionary:autoTrackerDic];
        }
    }
    
    NSDictionary *screenAutoTrackerAppidDic;
    if ([controller conformsToProtocol:@protocol(TDScreenAutoTracker)]) {
        UIViewController<TDScreenAutoTracker> *screenAutoTrackerController = (UIViewController<TDScreenAutoTracker> *)controller;
        if ([screenAutoTrackerController respondsToSelector:@selector(getScreenUrlWithAppid)])
            screenAutoTrackerAppidDic = [screenAutoTrackerController getScreenUrlWithAppid];
        if ([screenAutoTrackerController respondsToSelector:@selector(getScreenUrl)]) {
            NSString *currentUrl = [screenAutoTrackerController getScreenUrl];
            [properties setValue:currentUrl forKey:TD_EVENT_PROPERTY_URL_PROPERTY];
            [properties setValue:_referrerViewControllerUrl forKey:TD_EVENT_PROPERTY_REFERRER_URL];
            _referrerViewControllerUrl = currentUrl;
        }
    }
    
    NSDate *trackDate = [NSDate date];
    for (NSString *appid in self.autoTrackOptions) {
        ThinkingAnalyticsAutoTrackEventType type = [self.autoTrackOptions[appid] integerValue];
        if (type & ThinkingAnalyticsEventTypeAppViewScreen) {
            ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:appid];
            NSMutableDictionary *trackProperties = [properties mutableCopy];
            
            if ([instance isViewControllerIgnored:controller]
                || [instance isViewTypeIgnored:[controller class]]) {
                continue;
            }
            
            if (autoTrackerAppidDic && [autoTrackerAppidDic objectForKey:appid]) {
                NSDictionary *dic = [autoTrackerAppidDic objectForKey:appid];
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    [trackProperties addEntriesFromDictionary:dic];
                }
            }
            
            if (screenAutoTrackerAppidDic && [screenAutoTrackerAppidDic objectForKey:appid]) {
                NSString *screenUrl = [screenAutoTrackerAppidDic objectForKey:appid];
                [trackProperties setValue:screenUrl forKey:TD_EVENT_PROPERTY_URL_PROPERTY];
            }
            
            [instance autotrack:TD_APP_VIEW_EVENT properties:trackProperties withTime:trackDate];
        }
    }
}

- (BOOL)shouldTrackViewContrller:(Class)aClass {
    return ![TDPublicConfig.controllers containsObject:NSStringFromClass(aClass)];
}

- (ThinkingAnalyticsAutoTrackEventType)autoTrackOptionForAppid:(NSString *)appid {
    return (ThinkingAnalyticsAutoTrackEventType)[[self.autoTrackOptions objectForKey:appid] integerValue];
}

- (void)swizzleSelected:(UIView *)view delegate:(id)delegate {
    if ([view isKindOfClass:[UITableView class]]
        && [delegate conformsToProtocol:@protocol(UITableViewDelegate)]) {
        void (^block)(id, SEL, id, id) = ^(id target, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            [self trackEventView:tableView withIndexPath:indexPath];
        };
        
        [TDSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:)
                            onClass:[delegate class]
                          withBlock:block
                              named:@"td_table_select"];
    }
    
    if ([view isKindOfClass:[UICollectionView class]]
        && [delegate conformsToProtocol:@protocol(UICollectionViewDelegate)]) {
        
        void (^block)(id, SEL, id, id) = ^(id target, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
            [self trackEventView:collectionView withIndexPath:indexPath];
        };
        [TDSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:)
                            onClass:[delegate class]
                          withBlock:block
                              named:@"td_collection_select"];
    }
}

- (void)swizzleVC {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^tableViewBlock)(UITableView *tableView,
                               SEL cmd,
                               id<UITableViewDelegate> delegate) =
        ^(UITableView *tableView, SEL cmd, id<UITableViewDelegate> delegate) {
            if (!delegate) {
                return;
            }
            
            [self swizzleSelected:tableView delegate:delegate];
        };
        
        [TDSwizzler swizzleSelector:@selector(setDelegate:)
                            onClass:[UITableView class]
                          withBlock:tableViewBlock
                              named:@"td_table_delegate"];
        
        void (^collectionViewBlock)(UICollectionView *, SEL, id<UICollectionViewDelegate>) = ^(UICollectionView *collectionView, SEL cmd, id<UICollectionViewDelegate> delegate) {
            if (nil == delegate) {
                return;
            }
            
            [self swizzleSelected:collectionView delegate:delegate];
        };
        [TDSwizzler swizzleSelector:@selector(setDelegate:)
                            onClass:[UICollectionView class]
                          withBlock:collectionViewBlock
                              named:@"td_collection_delegate"];
        
        
        
        
        [UIViewController td_swizzleMethod:@selector(viewWillAppear:)
                                withMethod:@selector(td_autotrack_viewWillAppear:)
                                     error:NULL];
        
        [UIApplication td_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                             withMethod:@selector(td_sendAction:to:from:forEvent:)
                                  error:NULL];
    });
}

+ (NSString *)getPosition:(UIView *)view {
    NSString *position = nil;
    if ([view isKindOfClass:[UIView class]] && view.thinkingAnalyticsIgnoreView) {
        return nil;
    }
    
    if ([view isKindOfClass:[UITabBar class]]) {
        UITabBar *tabbar = (UITabBar *)view;
        position = [NSString stringWithFormat: @"%ld", (long)[tabbar.items indexOfObject:tabbar.selectedItem]];
    } else if ([view isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segment = (UISegmentedControl *)view;
        position = [NSString stringWithFormat:@"%ld", (long)segment.selectedSegmentIndex];
    } else if ([view isKindOfClass:[UIProgressView class]]) {
        UIProgressView *progress = (UIProgressView *)view;
        position = [NSString stringWithFormat:@"%f", progress.progress];
    } else if ([view isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)view;
        position = [NSString stringWithFormat:@"%ld", (long)pageControl.currentPage];
    }
    
    return position;
}

+ (NSString *)getText:(NSObject *)obj {
    NSString *text = nil;
    if ([obj isKindOfClass:[UIView class]] && [(UIView *)obj thinkingAnalyticsIgnoreView]) {
        return nil;
    }
    
    if ([obj isKindOfClass:[UIButton class]]) {
        text = ((UIButton *)obj).currentTitle;
    } else if ([obj isKindOfClass:[UITextView class]] ||
               [obj isKindOfClass:[UITextField class]]) {
        //ignore
    } else if ([obj isKindOfClass:[UILabel class]]) {
        text = ((UILabel *)obj).text;
    } else if ([obj isKindOfClass:[UIPickerView class]]) {
        UIPickerView *picker = (UIPickerView *)obj;
        NSInteger sections = picker.numberOfComponents;
        NSMutableArray *titles = [NSMutableArray array];
        
        for(NSInteger i = 0; i < sections; i++) {
            NSInteger row = [picker selectedRowInComponent:i];
            NSString *title;
            if ([picker.delegate
                 respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
                title = [picker.delegate pickerView:picker titleForRow:row forComponent:i];
            } else if ([picker.delegate
                        respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
                title = [picker.delegate
                         pickerView:picker
                         attributedTitleForRow:row forComponent:i].string;
            }
            [titles addObject:title ?: @""];
        }
        if (titles.count > 0) {
            text = [titles componentsJoinedByString:@","];
        }
    } else if ([obj isKindOfClass:[UIDatePicker class]]) {
        UIDatePicker *picker = (UIDatePicker *)obj;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = kDefaultTimeFormat;
        text = [formatter stringFromDate:picker.date];
    } else if ([obj isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segment = (UISegmentedControl *)obj;
        text =  [NSString stringWithFormat:@"%@", [segment titleForSegmentAtIndex:segment.selectedSegmentIndex]];
    } else if ([obj isKindOfClass:[UISwitch class]]) {
        UISwitch *switchItem = (UISwitch *)obj;
        text = switchItem.on ? @"on" : @"off";
    } else if ([obj isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)obj;
        text = [NSString stringWithFormat:@"%f", [slider value]];
    } else if ([obj isKindOfClass:[UIStepper class]]) {
        UIStepper *step = (UIStepper *)obj;
        text = [NSString stringWithFormat:@"%f", [step value]];
    } else {
        if ([obj isKindOfClass:[UIView class]]) {
            for(UIView *subView in [(UIView *)obj subviews]) {
                text = [TDAutoTrackManager getText:subView];
                if ([text isKindOfClass:[NSString class]] && text.length > 0) {
                    break;
                }
            }
        }
    }
    return text;
}

- (NSString *)titleFromViewController:(UIViewController *)viewController {
    if (!viewController) {
        return nil;
    }
    
    UIView *titleView = viewController.navigationItem.titleView;
    NSString *elementContent = nil;
    if (titleView) {
        elementContent = [TDAutoTrackManager getText:titleView];
    }
    
    return elementContent.length > 0 ? elementContent : viewController.navigationItem.title;
}

+ (UIWindow *)findWindow {
    UIWindow *window = [TDAppState sharedApplication].keyWindow;
    if (window == nil || window.windowLevel != UIWindowLevelNormal) {
        for (window in [TDAppState sharedApplication].windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, tvOS 13, *)) {
        NSSet *scenes = [[TDAppState sharedApplication] valueForKey:@"connectedScenes"];
        for (id scene in scenes) {
            if (window) {
                break;
            }
            
            id activationState = [scene valueForKeyPath:@"activationState"];
            BOOL isActive = activationState != nil && [activationState integerValue] == 0;
            if (isActive) {
                Class WindowScene = NSClassFromString(@"UIWindowScene");
                if ([scene isKindOfClass:WindowScene]) {
                    NSArray<UIWindow *> *windows = [scene valueForKeyPath:@"windows"];
                    for (UIWindow *w in windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
            }
        }
    }
#endif
    return window;
}

@end
