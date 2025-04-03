//
//  TDMediator.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/3/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * _Nonnull const kTDMediatorParamsKeySwiftTargetModuleName;

@interface TDMediator : NSObject

+ (instancetype)sharedInstance;

- (void)registerSuccessWithTargetName:(nonnull NSString *)targetName;

- (id _Nullable)performActionWithUrl:(NSURL * _Nullable)url completion:(void(^_Nullable)(NSDictionary * _Nullable info))completion;

- (id _Nullable)performTarget:(NSString * _Nonnull)targetName action:(NSString * _Nonnull)actionName params:(NSDictionary * _Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget;

- (id _Nullable)performTarget:(NSString * _Nonnull)targetName action:(NSString * _Nonnull)actionName params:(NSDictionary * _Nullable)params shouldCacheTarget:(BOOL)shouldCacheTarget needModuleReady:(BOOL)needModuleReady;

- (void)releaseCachedTargetWithFullTargetName:(NSString * _Nullable)fullTargetName;

- (BOOL)check:(NSString * _Nullable)targetName moduleName:(NSString * _Nullable)moduleName;

@end

NS_ASSUME_NONNULL_END
