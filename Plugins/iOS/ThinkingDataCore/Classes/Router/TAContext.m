//
//  TAContext.m
//  ThinkingSDK.default-Base-Core-Extension-Router-Util-iOS
//
//  Created by wwango on 2022/10/7.
//

#import "TAContext.h"

@interface TAContext()

@property(nonatomic, strong) NSMutableDictionary *modulesByName;

@property(nonatomic, strong) NSMutableDictionary *servicesByName;

@end


@implementation TAContext

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id instance = nil;
    
    dispatch_once(&p, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName
{
    [[TAContext shareInstance].servicesByName setObject:implInstance forKey:serviceName];
}

- (void)removeServiceWithServiceName:(NSString *)serviceName
{
    [[TAContext shareInstance].servicesByName removeObjectForKey:serviceName];
}

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName
{
    return [[TAContext shareInstance].servicesByName objectForKey:serviceName];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modulesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
        self.servicesByName  = [[NSMutableDictionary alloc] initWithCapacity:1];
    }

    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    TAContext *context = [[self.class allocWithZone:zone] init];
    
    context.application = self.application;
    context.launchOptions = self.launchOptions;
    context.customParam = self.customParam;

    return context;
}

@end
