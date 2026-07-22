//
//  TASuperProperty.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/10.
//

#import "TDSuperProperty.h"
#import "TDPropertyValidator.h"
#import "TDLogging.h"
#import "TDFile.h"

@interface TDSuperProperty ()
///multi-instance identifier
@property (nonatomic, copy) NSString *token;
/// static public property
@property (nonatomic, strong) NSDictionary *superProperties;
/// dynamic public properties
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
@property (nonatomic, strong) TDFile *file;
@property (nonatomic, assign) BOOL isLight;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation TDSuperProperty

- (instancetype)initWithToken:(NSString *)token isLight:(BOOL)isLight {
    if (self = [super init]) {
        self.lock = [[NSLock alloc] init];
        NSAssert(token.length > 0, @"token cant empty");
        self.token = token;
        self.isLight = isLight;
        if (!isLight) {
            self.file = [[TDFile alloc] initWithAppid:token];
            self.superProperties = [self.file unarchiveSuperProperties];
        }
    }
    return self;
}

- (void)registerSuperProperties:(NSDictionary *)properties {
    properties = [properties copy];
    properties = [TDPropertyValidator validateProperties:properties];
    if (properties.count <= 0) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }
    [self.lock lock];
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    [tmp addEntriesFromDictionary:properties];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    [self.file archiveSuperProperties:self.superProperties];
    [self.lock unlock];
    
    TDLogInfo(@"set super properties success");
}

- (void)unregisterSuperProperty:(NSString *)property {
    NSError *error = nil;
    [TDPropertyValidator validateEventOrPropertyName:property withError:&error];
    if (error) {
        return;
    }

    [self.lock lock];
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    tmp[property] = nil;
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    [self.file archiveSuperProperties:self.superProperties];
    [self.lock unlock];
    
    TDLogInfo(@"unset super properties success");
}

- (void)clearSuperProperties {
    [self.lock lock];
    self.superProperties = @{};
    [self.file archiveSuperProperties:self.superProperties];
    [self.lock unlock];
    TDLogInfo(@"clear super properties success");
}

- (NSDictionary *)currentSuperProperties {
    NSDictionary *result = nil;
    [self.lock lock];
    result = [self.superProperties copy] ?: @{};
    [self.lock unlock];
    return result;
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    [self.lock lock];
    self.dynamicSuperProperties = dynamicSuperProperties;
    [self.lock unlock];
}


- (NSDictionary *)obtainDynamicSuperProperties {
    NSDictionary *result = nil;
    [self.lock lock];
    if (self.dynamicSuperProperties) {
        NSDictionary *properties = self.dynamicSuperProperties();
        result = [TDPropertyValidator validateProperties:[properties copy]];
    }
    [self.lock unlock];
    return result;
}

@end
