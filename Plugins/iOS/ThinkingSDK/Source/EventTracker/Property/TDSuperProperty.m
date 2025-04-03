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
@property (atomic, strong) NSDictionary *superProperties;
/// dynamic public properties
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
@property (nonatomic, strong) TDFile *file;
@property (nonatomic, assign) BOOL isLight;

@end

@implementation TDSuperProperty

- (instancetype)initWithToken:(NSString *)token isLight:(BOOL)isLight {
    if (self = [super init]) {
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

    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    
    [tmp addEntriesFromDictionary:properties];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];

    
    [self.file archiveSuperProperties:self.superProperties];
    TDLogInfo(@"set super properties success");
}

- (void)unregisterSuperProperty:(NSString *)property {
    NSError *error = nil;
    [TDPropertyValidator validateEventOrPropertyName:property withError:&error];
    if (error) {
        return;
    }

    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    tmp[property] = nil;
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    
    [self.file archiveSuperProperties:self.superProperties];
    TDLogInfo(@"unset super properties success");
}

- (void)clearSuperProperties {
    self.superProperties = @{};
    [self.file archiveSuperProperties:self.superProperties];
    TDLogInfo(@"clear super properties success");
}

- (NSDictionary *)currentSuperProperties {
    if (self.superProperties) {
        return [TDPropertyValidator validateProperties:[self.superProperties copy]];
    } else {
        return @{};
    }
}

- (void)registerDynamicSuperProperties:(NSDictionary<NSString *, id> *(^ _Nullable)(void))dynamicSuperProperties {
    @synchronized (self) {
        self.dynamicSuperProperties = dynamicSuperProperties;
    }
}


- (NSDictionary *)obtainDynamicSuperProperties {
    @synchronized (self) {
        if (self.dynamicSuperProperties) {
            NSDictionary *properties = self.dynamicSuperProperties();
            NSDictionary *validProperties = [TDPropertyValidator validateProperties:[properties copy]];
            return validProperties;
        }
        return nil;
    }
}

@end
