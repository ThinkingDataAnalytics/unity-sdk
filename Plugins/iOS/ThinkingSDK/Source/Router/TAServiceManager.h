//
//  TAServiceManager.h
//  ThinkingSDK.default-Base-Core-Extension-Router-Util-iOS
//
//  Created by wwango on 2022/10/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAServiceManager : NSObject

@property (nonatomic, assign) BOOL  enableException;

+ (instancetype)sharedManager;

- (void)registerLocalServices;

- (void)registerService:(Protocol *)service implClass:(Class)implClass;

- (id)createService:(Protocol *)service;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName;
- (id)createService:(Protocol *)service withServiceName:(NSString *)serviceName shouldCache:(BOOL)shouldCache;

@end

NS_ASSUME_NONNULL_END
