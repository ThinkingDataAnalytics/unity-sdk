//
//  TDMediator.m
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/6.
//

#import "TDMediator.h"
#import "TDCoreLog.h"

NSString * const kTDMediatorParamsKeySwiftTargetModuleName = @"kTDMediatorParamsKeySwiftTargetModuleName";

@interface TDMediatorPerformInstance : NSObject
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, copy) NSString *actionName;
@property (nonatomic, strong) NSDictionary *params;

@end

@implementation TDMediatorPerformInstance
@end


@interface TDMediator ()
@property (nonatomic, strong) NSMutableDictionary *cachedTarget;
@property (nonatomic, strong) NSMutableArray<NSString *> *registerTargetNames;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<TDMediatorPerformInstance *> *> *cachedPerformInstance;

@end

@implementation TDMediator

+ (instancetype)sharedInstance {
    static TDMediator *mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[TDMediator alloc] init];
    });
    return mediator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedTarget = [[NSMutableDictionary alloc] init];
        self.registerTargetNames = [NSMutableArray array];
        self.cachedPerformInstance = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerSuccessWithTargetName:(NSString *)targetName {
    if ([targetName isKindOfClass:NSString.class] && targetName.length > 0) {
        @synchronized (self) {
            [self.registerTargetNames addObject:targetName];
            NSMutableArray<TDMediatorPerformInstance *> *cached = self.cachedPerformInstance[targetName];
            for (TDMediatorPerformInstance *instance in cached) {
                [self performTarget:instance.targetName action:instance.actionName params:instance.params shouldCacheTarget:NO];
            }
            self.cachedPerformInstance[targetName] = [NSMutableArray array];
        }
    }
}

/// call by url
/// - Parameters:
///   - url: scheme://[target]/[action]?[params]  e.g. aaa://targetA/actionB?id=1234
///   - completion: completion description
- (id)performActionWithUrl:(NSURL *)url completion:(void (^)(NSDictionary * _Nullable))completion {
    if (url == nil||![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.value&&obj.name) {
            [params setObject:obj.value forKey:obj.name];
        }
    }];
    
    // refuse calls apis which only for local through remote url
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    id result = [self performTarget:url.host action:actionName params:params shouldCacheTarget:NO];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    return result;
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget {
    return [self performTarget:targetName action:actionName params:params shouldCacheTarget:shouldCacheTarget needModuleReady:NO];
}

- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget needModuleReady:(BOOL)needModuleReady {
    if (targetName == nil || actionName == nil) {
        return nil;
    }
    
    if (needModuleReady) {
        @synchronized (self) {
            if (![self.registerTargetNames containsObject:targetName]) {
                NSMutableArray<TDMediatorPerformInstance *> *cached = self.cachedPerformInstance[targetName];
                if (!cached) {
                    cached = [NSMutableArray array];
                    self.cachedPerformInstance[targetName] = cached;
                }
                TDMediatorPerformInstance *instance = [[TDMediatorPerformInstance alloc] init];
                instance.targetName = targetName;
                instance.actionName = actionName;
                instance.params = params;
                if (cached.count < 100) {
                    [cached addObject:instance];
                    [TDCoreLog printLog:@"Router cache successed. target: %@, action: %@, params: %@", targetName, actionName, params];
                } else {
                    [TDCoreLog printLog:@"Router Cache fulled. Drop it. target: %@, action: %@, params: %@", targetName, actionName, params];
                }
                return nil;
            }
        }
    }
    
    NSString *swiftModuleName = params[kTDMediatorParamsKeySwiftTargetModuleName];
    
    // generate target
    NSString *targetClassString = nil;
    if (swiftModuleName.length > 0) {
        targetClassString = [NSString stringWithFormat:@"%@.Target_%@", swiftModuleName, targetName];
    } else {
        targetClassString = [NSString stringWithFormat:@"Target_%@", targetName];
    }
    NSObject *target = [self safeFetchCachedTarget:targetClassString];
    if (target == nil) {
        Class targetClass = NSClassFromString(targetClassString);
        target = [[targetClass alloc] init];
    }

    // generate action
    NSString *actionString = [NSString stringWithFormat:@"Action_%@:", actionName];
    SEL action = NSSelectorFromString(actionString);
    
    if (target == nil) {
        // process no target-action calling
        [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
        return nil;
    }
    
    if (shouldCacheTarget) {
        [self safeSetCachedTarget:target key:targetClassString];
    }

    if ([target respondsToSelector:action]) {
        return [self safePerformAction:action target:target params:params];
    } else {
        // call default function "notFound:" in target when action is not found
        SEL action = NSSelectorFromString(@"notFound:");
        if ([target respondsToSelector:action]) {
            return [self safePerformAction:action target:target params:params];
        } else {
            // process no target-action calling
            [self NoTargetActionResponseWithTargetString:targetClassString selectorString:actionString originParams:params];
            @synchronized (self) {
                [self.cachedTarget removeObjectForKey:targetClassString];
            }
            return nil;
        }
    }
}

/// release cache
/// - Parameter fullTargetName: OC: e.g.  Target_XXX.  Swift: e.g. XXXModule.Target_YYY
- (void)releaseCachedTargetWithFullTargetName:(NSString *)fullTargetName {
    if (fullTargetName == nil) {
        return;
    }
    @synchronized (self) {
        [self.cachedTarget removeObjectForKey:fullTargetName];
    }
}

- (BOOL)check:(NSString * _Nullable)targetName moduleName:(NSString * _Nullable)moduleName{
    if (moduleName.length > 0) {
        return NSClassFromString([NSString stringWithFormat:@"%@.Target_%@", moduleName, targetName]) != nil;
    } else {
        return NSClassFromString([NSString stringWithFormat:@"Target_%@", targetName]) != nil;
    }
}

- (void)NoTargetActionResponseWithTargetString:(NSString *)targetString selectorString:(NSString *)selectorString originParams:(NSDictionary *)originParams {
    SEL action = NSSelectorFromString(@"Action_response:");
    NSObject *target = [[NSClassFromString(@"Target_NoTargetAction") alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"originParams"] = originParams;
    params[@"targetString"] = targetString;
    params[@"selectorString"] = selectorString;
    
    [self safePerformAction:action target:target params:params];
}

- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params {
    NSMethodSignature *methodSig = [target methodSignatureForSelector:action];
    if (methodSig == nil) {
        return nil;
    }
    const char *retType = [methodSig methodReturnType];

    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    }

    if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(BOOL)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(CGFloat)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

    if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
}

#pragma mark - getters and setters

- (NSObject *)safeFetchCachedTarget:(NSString *)key {
    @synchronized (self) {
        return self.cachedTarget[key];
    }
}

- (void)safeSetCachedTarget:(NSObject *)target key:(NSString *)key {
    @synchronized (self) {
        self.cachedTarget[key] = target;
    }
}

@end
