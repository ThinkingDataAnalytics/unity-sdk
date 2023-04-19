//
//  TASuperProperty.m
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/6/10.
//

#import "TASuperProperty.h"
#import "TAPropertyValidator.h"
#import "TDLogging.h"
#import "TDFile.h"

@interface TASuperProperty ()
///multi-instance identifier
@property (nonatomic, copy) NSString *token;
/// static public property
@property (atomic, strong) NSDictionary *superProperties;
/// dynamic public properties
@property (nonatomic, copy) NSDictionary<NSString *, id> *(^dynamicSuperProperties)(void);
@property (nonatomic, strong) TDFile *file;
@property (nonatomic, assign) BOOL isLight;

@end

@implementation TASuperProperty

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
    
    properties = [TAPropertyValidator validateProperties:properties];
    if (properties.count <= 0) {
        TDLogError(@"%@ propertieDict error.", properties);
        return;
    }

    
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    
    [tmp addEntriesFromDictionary:properties];
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];

    
    [self.file archiveSuperProperties:self.superProperties];
}

- (void)unregisterSuperProperty:(NSString *)property {
    NSError *error = nil;
    [TAPropertyValidator validateEventOrPropertyName:property withError:&error];
    if (error) {
        return;
    }

    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:self.superProperties];
    tmp[property] = nil;
    self.superProperties = [NSDictionary dictionaryWithDictionary:tmp];
    
    [self.file archiveSuperProperties:self.superProperties];
}

- (void)clearSuperProperties {
    self.superProperties = @{};
    [self.file archiveSuperProperties:self.superProperties];
}

- (NSDictionary *)currentSuperProperties {
    if (self.superProperties) {
        return [TAPropertyValidator validateProperties:[self.superProperties copy]];
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
            
            NSDictionary *validProperties = [TAPropertyValidator validateProperties:[properties copy]];
            return validProperties;
        }
        return nil;
    }
}

@end
