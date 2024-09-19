//
//  TAModuleManager.m
//  Pods
//
//  Created by wwango on 2022/10/8.
//

#import "TAModuleManager.h"
#import "TAModuleProtocol.h"
#import "TAContext.h"

#define kTAModuleArrayKey     @"moduleClasses"
#define kTAModuleInfoNameKey  @"moduleClass"
#define kTAModuleInfoLevelKey @"moduleLevel"
#define kTAModuleInfoPriorityKey @"modulePriority"
#define kTAModuleInfoHasInstantiatedKey @"moduleHasInstantiated"

static  NSString *kTASetupSelector = @"modSetUp:";
static  NSString *kTAInitSelector = @"modInit:";
static  NSString *kTASplashSeletor = @"modSplash:";
static  NSString *kTATearDownSelector = @"modTearDown:";
static  NSString *kTAWillResignActiveSelector = @"modWillResignActive:";
static  NSString *kTADidEnterBackgroundSelector = @"modDidEnterBackground:";
static  NSString *kTAWillEnterForegroundSelector = @"modWillEnterForeground:";
static  NSString *kTADidBecomeActiveSelector = @"modDidBecomeActive:";
static  NSString *kTAWillTerminateSelector = @"modWillTerminate:";
static  NSString *kTAUnmountEventSelector = @"modUnmount:";
static  NSString *kTAQuickActionSelector = @"modQuickAction:";
static  NSString *kTAOpenURLSelector = @"modOpenURL:";
static  NSString *kTADidReceiveMemoryWarningSelector = @"modDidReceiveMemoryWaring:";
static  NSString *kTAFailToRegisterForRemoteNotificationsSelector = @"modDidFailToRegisterForRemoteNotifications:";
static  NSString *kTADidRegisterForRemoteNotificationsSelector = @"modDidRegisterForRemoteNotifications:";
static  NSString *kTADidReceiveRemoteNotificationsSelector = @"modDidReceiveRemoteNotification:";
static  NSString *kTADidReceiveLocalNotificationsSelector = @"modDidReceiveLocalNotification:";
static  NSString *kTAWillPresentNotificationSelector = @"modWillPresentNotification:";
static  NSString *kTADidReceiveNotificationResponseSelector = @"modDidReceiveNotificationResponse:";
static  NSString *kTAWillContinueUserActivitySelector = @"modWillContinueUserActivity:";
static  NSString *kTAContinueUserActivitySelector = @"modContinueUserActivity:";
static  NSString *kTADidUpdateContinueUserActivitySelector = @"modDidUpdateContinueUserActivity:";
static  NSString *kTAFailToContinueUserActivitySelector = @"modDidFailToContinueUserActivity:";
static  NSString *kTAHandleWatchKitExtensionRequestSelector = @"modHandleWatchKitExtensionRequest:";
static  NSString *kTAAppCustomSelector = @"modDidCustomEvent:";


@interface TAModuleManager ()

@property(nonatomic, strong) NSMutableArray     *TAModuleDynamicClasses;

@property(nonatomic, strong) NSMutableArray<NSDictionary *>     *TAModuleInfos;
@property(nonatomic, strong) NSMutableArray     *TAModules;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<id<TAModuleProtocol>> *> *TAModulesByEvent;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *TASelectorByEvent;

@end


@implementation TAModuleManager


+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TAModuleManager alloc] init];
    });
    return sharedManager;
}

- (void)loadLocalModules
{
    
}

- (void)registerDynamicModule:(Class)moduleClass
{
    [self addModuleFromObject:moduleClass];
}

- (void)unRegisterDynamicModule:(Class)moduleClass {
    if (!moduleClass) {
        return;
    }
    [self.TAModuleInfos filterUsingPredicate:[NSPredicate predicateWithFormat:@"%@!=%@", kTAModuleInfoNameKey, NSStringFromClass(moduleClass)]];
    __block NSInteger index = -1;
    [self.TAModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:moduleClass]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        [self.TAModules removeObjectAtIndex:index];
    }
    [self.TAModulesByEvent enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSMutableArray<id<TAModuleProtocol>> * _Nonnull obj, BOOL * _Nonnull stop) {
        __block NSInteger index = -1;
        [obj enumerateObjectsUsingBlock:^(id<TAModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:moduleClass]) {
                index = idx;
                *stop = NO;
            }
        }];
        if (index >= 0) {
            [obj removeObjectAtIndex:index];
        }
    }];
}

- (void)registedAllModules
{
    [self.TAModuleInfos sortUsingComparator:^NSComparisonResult(NSDictionary *module1, NSDictionary *module2) {
        NSNumber *module1Level = (NSNumber *)[module1 objectForKey:kTAModuleInfoLevelKey];
        NSNumber *module2Level =  (NSNumber *)[module2 objectForKey:kTAModuleInfoLevelKey];
        if (module1Level.integerValue != module2Level.integerValue) {
            return module1Level.integerValue > module2Level.integerValue;
        } else {
            NSNumber *module1Priority = (NSNumber *)[module1 objectForKey:kTAModuleInfoPriorityKey];
            NSNumber *module2Priority = (NSNumber *)[module2 objectForKey:kTAModuleInfoPriorityKey];
            return module1Priority.integerValue < module2Priority.integerValue;
        }
    }];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    //module init
    [self.TAModuleInfos enumerateObjectsUsingBlock:^(NSDictionary *module, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *classStr = [module objectForKey:kTAModuleInfoNameKey];
        
        Class moduleClass = NSClassFromString(classStr);
        BOOL hasInstantiated = ((NSNumber *)[module objectForKey:kTAModuleInfoHasInstantiatedKey]).boolValue;
        if (NSStringFromClass(moduleClass) && !hasInstantiated) {
            id<TAModuleProtocol> moduleInstance = [[moduleClass alloc] init];
            [tmpArray addObject:moduleInstance];
        }
        
    }];
    
    [self.TAModules addObjectsFromArray:tmpArray];
    
    [self registerAllSystemEvents];
}

- (void)registerCustomEvent:(NSInteger)eventType
   withModuleInstance:(id)moduleInstance
       andSelectorStr:(NSString *)selectorStr {
    if (eventType < 1000) {
        return;
    }
    [self registerEvent:eventType withModuleInstance:moduleInstance andSelectorStr:selectorStr];
}

- (void)triggerEvent:(NSInteger)eventType
{
    [self triggerEvent:eventType withCustomParam:nil];
}

- (void)triggerEvent:(NSInteger)eventType withCustomParam:(NSDictionary *)customParam {
    [self handleModuleEvent:eventType forTarget:nil withCustomParam:customParam];
}

#pragma mark - life loop

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.TAModuleDynamicClasses = [NSMutableArray array];
    }
    return self;
}

#pragma mark - private

- (TAModuleLevel)checkModuleLevel:(NSUInteger)level
{
    switch (level) {
        case 0:
            return TAModuleBasic;
            break;
        case 1:
            return TAModuleNormal;
            break;
        default:
            break;
    }
    //default normal
    return TAModuleNormal;
}


- (void)addModuleFromObject:(id)object
{
    Class class;
    NSString *moduleName = nil;
    
    if (object) {
        class = object;
        moduleName = NSStringFromClass(class);
    } else {
        return ;
    }
    
    __block BOOL flag = YES;
    [self.TAModules enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:class]) {
            flag = NO;
            *stop = YES;
        }
    }];
    if (!flag) {
        return;
    }
    
    if ([class conformsToProtocol:@protocol(TAModuleProtocol)]) {
        NSMutableDictionary *moduleInfo = [NSMutableDictionary dictionary];
        
        BOOL responseBasicLevel = [class instancesRespondToSelector:@selector(basicModuleLevel)];

        int levelInt = 1;
        
        if (responseBasicLevel) {
            levelInt = 0;
        }
        
        [moduleInfo setObject:@(levelInt) forKey:kTAModuleInfoLevelKey];
        if (moduleName) {
            [moduleInfo setObject:moduleName forKey:kTAModuleInfoNameKey];
        }

        [self.TAModuleInfos addObject:moduleInfo];
        
        id<TAModuleProtocol> moduleInstance = [[class alloc] init];
        [self.TAModules addObject:moduleInstance];
        [moduleInfo setObject:@(YES) forKey:kTAModuleInfoHasInstantiatedKey];
        [self.TAModules sortUsingComparator:^NSComparisonResult(id<TAModuleProtocol> moduleInstance1, id<TAModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(TAModuleNormal);
            NSNumber *module2Level = @(TAModuleNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(TAModuleBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(TAModuleBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
        [self registerEventsByModuleInstance:moduleInstance];
        
        [self handleModuleEvent:TAMSetupEvent forTarget:moduleInstance withSeletorStr:nil andCustomParam:nil];
        [self handleModulesInitEventForTarget:moduleInstance withCustomParam:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleModuleEvent:TAMSplashEvent forTarget:moduleInstance withSeletorStr:nil andCustomParam:nil];
        });
    }
}

- (void)registerAllSystemEvents
{
    [self.TAModules enumerateObjectsUsingBlock:^(id<TAModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEventsByModuleInstance:moduleInstance];
    }];
}

- (void)registerEventsByModuleInstance:(id<TAModuleProtocol>)moduleInstance
{
    NSArray<NSNumber *> *events = self.TASelectorByEvent.allKeys;
    [events enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerEvent:obj.integerValue withModuleInstance:moduleInstance andSelectorStr:self.TASelectorByEvent[obj]];
    }];
}

- (void)registerEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr {
    SEL selector = NSSelectorFromString(selectorStr);
    if (!selector || ![moduleInstance respondsToSelector:selector]) {
        return;
    }
    NSNumber *eventTypeNumber = @(eventType);
    if (!self.TASelectorByEvent[eventTypeNumber]) {
        [self.TASelectorByEvent setObject:selectorStr forKey:eventTypeNumber];
    }
    if (!self.TAModulesByEvent[eventTypeNumber]) {
        [self.TAModulesByEvent setObject:@[].mutableCopy forKey:eventTypeNumber];
    }
    NSMutableArray *eventModules = [self.TAModulesByEvent objectForKey:eventTypeNumber];
    if (![eventModules containsObject:moduleInstance]) {
        [eventModules addObject:moduleInstance];
        [eventModules sortUsingComparator:^NSComparisonResult(id<TAModuleProtocol> moduleInstance1, id<TAModuleProtocol> moduleInstance2) {
            NSNumber *module1Level = @(TAModuleNormal);
            NSNumber *module2Level = @(TAModuleNormal);
            if ([moduleInstance1 respondsToSelector:@selector(basicModuleLevel)]) {
                module1Level = @(TAModuleBasic);
            }
            if ([moduleInstance2 respondsToSelector:@selector(basicModuleLevel)]) {
                module2Level = @(TAModuleBasic);
            }
            if (module1Level.integerValue != module2Level.integerValue) {
                return module1Level.integerValue > module2Level.integerValue;
            } else {
                NSInteger module1Priority = 0;
                NSInteger module2Priority = 0;
                if ([moduleInstance1 respondsToSelector:@selector(modulePriority)]) {
                    module1Priority = [moduleInstance1 modulePriority];
                }
                if ([moduleInstance2 respondsToSelector:@selector(modulePriority)]) {
                    module2Priority = [moduleInstance2 modulePriority];
                }
                return module1Priority < module2Priority;
            }
        }];
    }
}


#pragma mark - property setter or getter
- (NSMutableArray<NSDictionary *> *)TAModuleInfos {
    if (!_TAModuleInfos) {
        _TAModuleInfos = @[].mutableCopy;
    }
    return _TAModuleInfos;
}

- (NSMutableArray *)TAModules
{
    if (!_TAModules) {
        _TAModules = [NSMutableArray array];
    }
    return _TAModules;
}

- (NSMutableDictionary<NSNumber *, NSMutableArray<id<TAModuleProtocol>> *> *)TAModulesByEvent
{
    if (!_TAModulesByEvent) {
        _TAModulesByEvent = @{}.mutableCopy;
    }
    return _TAModulesByEvent;
}

- (NSMutableDictionary<NSNumber *, NSString *> *)TASelectorByEvent
{
    if (!_TASelectorByEvent) {
        _TASelectorByEvent = @{
                               @(TAMSetupEvent):kTASetupSelector,
                               @(TAMInitEvent):kTAInitSelector,
                               @(TAMTearDownEvent):kTATearDownSelector,
                               @(TAMSplashEvent):kTASplashSeletor,
                               @(TAMWillResignActiveEvent):kTAWillResignActiveSelector,
                               @(TAMDidEnterBackgroundEvent):kTADidEnterBackgroundSelector,
                               @(TAMWillEnterForegroundEvent):kTAWillEnterForegroundSelector,
                               @(TAMDidBecomeActiveEvent):kTADidBecomeActiveSelector,
                               @(TAMWillTerminateEvent):kTAWillTerminateSelector,
                               @(TAMUnmountEvent):kTAUnmountEventSelector,
                               @(TAMOpenURLEvent):kTAOpenURLSelector,
                               @(TAMDidReceiveMemoryWarningEvent):kTADidReceiveMemoryWarningSelector,
                               
                               @(TAMDidReceiveRemoteNotificationEvent):kTADidReceiveRemoteNotificationsSelector,
                               @(TAMWillPresentNotificationEvent):kTAWillPresentNotificationSelector,
                               @(TAMDidReceiveNotificationResponseEvent):kTADidReceiveNotificationResponseSelector,
                               
                               @(TAMDidFailToRegisterForRemoteNotificationsEvent):kTAFailToRegisterForRemoteNotificationsSelector,
                               @(TAMDidRegisterForRemoteNotificationsEvent):kTADidRegisterForRemoteNotificationsSelector,
                               
                               @(TAMDidReceiveLocalNotificationEvent):kTADidReceiveLocalNotificationsSelector,
                               
                               @(TAMWillContinueUserActivityEvent):kTAWillContinueUserActivitySelector,
                               
                               @(TAMContinueUserActivityEvent):kTAContinueUserActivitySelector,
                               
                               @(TAMDidFailToContinueUserActivityEvent):kTAFailToContinueUserActivitySelector,
                               
                               @(TAMDidUpdateUserActivityEvent):kTADidUpdateContinueUserActivitySelector,
                               
                               @(TAMQuickActionEvent):kTAQuickActionSelector,
                               @(TAMDidCustomEvent):kTAAppCustomSelector,
                               }.mutableCopy;
    }
    return _TASelectorByEvent;
}

#pragma mark - module protocol
- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<TAModuleProtocol>)target
          withCustomParam:(NSDictionary *)customParam
{
    switch (eventType) {
        case TAMInitEvent:
            //special
            [self handleModulesInitEventForTarget:nil withCustomParam :customParam];
            break;
        case TAMTearDownEvent:
            //special
            [self handleModulesTearDownEventForTarget:nil withCustomParam:customParam];
            break;
        default: {
            NSString *selectorStr = [self.TASelectorByEvent objectForKey:@(eventType)];
            [self handleModuleEvent:eventType forTarget:nil withSeletorStr:selectorStr andCustomParam:customParam];
        }
            break;
    }
    
}

- (void)handleModulesInitEventForTarget:(id<TAModuleProtocol>)target
                        withCustomParam:(NSDictionary *)customParam
{
    TAContext *context = [TAContext shareInstance].copy;
    
    NSArray<id<TAModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.TAModulesByEvent objectForKey:@(TAMInitEvent)];
    }
    
    [moduleInstances enumerateObjectsUsingBlock:^(id<TAModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        __weak __typeof(&*self) wself = self;
        void ( ^ bk )(void);
        bk = ^(){
            __strong __typeof(&*self) sself = wself;
            if (sself) {
                if ([moduleInstance respondsToSelector:@selector(modInit:)]) {
                    [moduleInstance modInit:context];
                }
            }
        };

        if ([moduleInstance respondsToSelector:@selector(async)]) {
            BOOL async = [moduleInstance async];
            
            if (async) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bk();
                });
                
            } else {
                bk();
            }
        } else {
            bk();
        }
    }];
}

- (void)handleModulesTearDownEventForTarget:(id<TAModuleProtocol>)target
                            withCustomParam:(NSDictionary *)customParam
{
    TAContext *context = [TAContext shareInstance].copy;
    
    NSArray<id<TAModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.TAModulesByEvent objectForKey:@(TAMTearDownEvent)];
    }

    //Reverse Order to unload
    for (int i = (int)moduleInstances.count - 1; i >= 0; i--) {
        id<TAModuleProtocol> moduleInstance = [moduleInstances objectAtIndex:i];
        if (moduleInstance && [moduleInstance respondsToSelector:@selector(modTearDown:)]) {
            [moduleInstance modTearDown:context];
        }
    }
}


- (void)handleModuleEvent:(NSInteger)eventType
                forTarget:(id<TAModuleProtocol>)target
           withSeletorStr:(NSString *)selectorStr
           andCustomParam:(NSDictionary *)customParam
{
    TAContext *context = [TAContext shareInstance].copy;
    context.customParam = customParam;
    if (!selectorStr.length) {
        selectorStr = [self.TASelectorByEvent objectForKey:@(eventType)];
    }
    SEL seletor = NSSelectorFromString(selectorStr);
    if (!seletor) {
        selectorStr = [self.TASelectorByEvent objectForKey:@(eventType)];
        seletor = NSSelectorFromString(selectorStr);
    }
    NSArray<id<TAModuleProtocol>> *moduleInstances;
    if (target) {
        moduleInstances = @[target];
    } else {
        moduleInstances = [self.TAModulesByEvent objectForKey:@(eventType)];
    }
    [moduleInstances enumerateObjectsUsingBlock:^(id<TAModuleProtocol> moduleInstance, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([moduleInstance respondsToSelector:seletor]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [moduleInstance performSelector:seletor withObject:context];
#pragma clang diagnostic pop
        }
    }];
}


@end
