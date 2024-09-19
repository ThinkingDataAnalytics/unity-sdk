//
//  TARouter.h
//  Pods
//
//  Created by wwango on 2022/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const TARURLSchemeGlobalKey = @"URLGlobalScheme";
static NSString *const TARURLHostCallService = @"call.service.thinkingdata";
static NSString *const TARURLHostRegister = @"register.thinking";
static NSString *const TARURLSubPathSplitPattern = @".";
static NSString *const TARURLQueryParamsKey = @"params";

typedef void(^TARPathComponentCustomHandler)(NSDictionary<NSString *, id> *params);

@interface TARouter : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)globalRouter;
+ (instancetype)routerForScheme:(NSString *)scheme;

//url - >  com.thinkingdata://call.service/pathComponentKey.protocolName.selector/...?params={}(value url encode)
+ (BOOL)canOpenURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params;
+ (BOOL)openURL:(NSURL *)URL
     withParams:(NSDictionary<NSString *, NSDictionary<NSString *, id> *> *)params
        andThen:(void(^)(NSString *pathComponentKey, id obj, id returnValue))then;
@end

NS_ASSUME_NONNULL_END
