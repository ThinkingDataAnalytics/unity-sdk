//
//  TAAppLifeCycle.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/28.
//

#import "TAAppLifeCycle.h"
#import "TDAppState.h"

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#if __has_include(<ThinkingSDK/TDLogging.h>)
#import <ThinkingSDK/TDLogging.h>
#else
#import "TDLogging.h"
#endif

NSNotificationName const kTAAppLifeCycleStateWillChangeNotification = @"cn.thinkingdata.TAAppLifeCycleStateWillChange";
NSNotificationName const kTAAppLifeCycleStateDidChangeNotification = @"cn.thinkingdata.TAAppLifeCycleStateDidChange";
NSString * const kTAAppLifeCycleNewStateKey = @"new";
NSString * const kTAAppLifeCycleOldStateKey = @"old";


@interface TAAppLifeCycle ()
/// status
@property (nonatomic, assign) TAAppLifeCycleState state;

@end

@implementation TAAppLifeCycle

+ (void)startMonitor {
    [TAAppLifeCycle shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TAAppLifeCycle *appLifeCycle = nil;
    dispatch_once(&onceToken, ^{
        appLifeCycle = [[TAAppLifeCycle alloc] init];
    });
    return appLifeCycle;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = TAAppLifeCycleStateInit;
        [self registerListeners];
        [self setupLaunchedState];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerListeners {
    if ([TDAppState runningInAppExtension]) {
        return;
    }

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
#if TARGET_OS_IOS
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];

#elif TARGET_OS_OSX

//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidFinishLaunching:)
//                               name:NSApplicationDidFinishLaunchingNotification
//                             object:nil];
//
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidBecomeActive:)
//                               name:NSApplicationDidBecomeActiveNotification
//                             object:nil];
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationDidResignActive:)
//                               name:NSApplicationDidResignActiveNotification
//                             object:nil];
//
//    [notificationCenter addObserver:self
//                           selector:@selector(applicationWillTerminate:)
//                               name:NSApplicationWillTerminateNotification
//                             object:nil];
#endif
}

- (void)setupLaunchedState {
    if ([TDAppState runningInAppExtension]) {
        return;
    }
    
    dispatch_block_t mainThreadBlock = ^(){
#if TARGET_OS_IOS
        UIApplication *application = [TDAppState sharedApplication];
        BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
        BOOL isAppStateBackground = NO;
#endif
        [TDAppState shareInstance].relaunchInBackground = isAppStateBackground;

        self.state = isAppStateBackground ? TAAppLifeCycleStateBackgroundStart : TAAppLifeCycleStateStart;
    };

    if (@available(iOS 13.0, *)) {
        // The reason why iOS 13 and above modify the status in the block of the asynchronous main queue:+
        // 1. Make sure that the initialization of the SDK has been completed before sending the appstatus change notification. This can ensure that the public properties have been set when the automatic collection management class sends the app_start event (in fact, it can also be achieved by listening to UIApplicationDidFinishLaunchingNotification)
        // 2. In a project that contains SceneDelegate, it is accurate to delay obtaining applicationState (obtaining by listening to UIApplicationDidFinishLaunchingNotification is inaccurate)
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    } else {
        // iOS 13 and below handle background wakeup and cold start (non-delayed initialization) by listening to the notification of UIApplicationDidFinishLaunchingNotification:
        // 1. When iOS 13 or later wakes up in the background, the block of the asynchronous main queue will not be executed. So you need to listen to UIApplicationDidFinishLaunchingNotification at the same time
        // 2. iOS 13 and below will not contain SceneDelegate
#if TARGET_OS_IOS
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
#endif
        // Handle cold start below iOS 13, where the client delays initialization. UIApplicationDidFinishLaunchingNotification notification has been missed when lazy initialization
        dispatch_async(dispatch_get_main_queue(), mainThreadBlock);
    }
}

//MARK: - Notification Action

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
#if TARGET_OS_IOS
    UIApplication *application = [TDAppState sharedApplication];
    BOOL isAppStateBackground = application.applicationState == UIApplicationStateBackground;
#else
    BOOL isAppStateBackground = NO;
#endif

    [TDAppState shareInstance].relaunchInBackground = isAppStateBackground;
    
    self.state = isAppStateBackground ? TAAppLifeCycleStateBackgroundStart : TAAppLifeCycleStateStart;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    TDLogDebug(@"application did become active");

#if TARGET_OS_IOS
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
#elif TARGET_OS_OSX
    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (!application.isActive) {
        return;
    }
#endif

    [TDAppState shareInstance].relaunchInBackground = NO;

    self.state = TAAppLifeCycleStateStart;
}

#if TARGET_OS_IOS
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    TDLogDebug(@"application did enter background");
    
    if (![notification.object isKindOfClass:[UIApplication class]]) {
        return;
    }

    UIApplication *application = (UIApplication *)notification.object;
    if (application.applicationState != UIApplicationStateBackground) {
        return;
    }

    self.state = TAAppLifeCycleStateEnd;
}

#elif TARGET_OS_OSX
- (void)applicationDidResignActive:(NSNotification *)notification {
    TDLogDebug(@"application did resignActive");

    if (![notification.object isKindOfClass:[NSApplication class]]) {
        return;
    }

    NSApplication *application = (NSApplication *)notification.object;
    if (application.isActive) {
        return;
    }
    self.state = TAAppLifeCycleStateEnd;
}
#endif

- (void)applicationWillTerminate:(NSNotification *)notification {
    TDLogDebug(@"application will terminate");

    self.state = TAAppLifeCycleStateTerminate;
}

//MARK: - Setter

- (void)setState:(TAAppLifeCycleState)state {

    if (_state == state) {
        return;
    }
    
    [TDAppState shareInstance].isActive = (state == TAAppLifeCycleStateStart);

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    userInfo[kTAAppLifeCycleNewStateKey] = @(state);
    userInfo[kTAAppLifeCycleOldStateKey] = @(_state);

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateWillChangeNotification object:self userInfo:userInfo];

    _state = state;

    [[NSNotificationCenter defaultCenter] postNotificationName:kTAAppLifeCycleStateDidChangeNotification object:self userInfo:userInfo];
}

@end
