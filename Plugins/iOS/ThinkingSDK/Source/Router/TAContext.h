//
//  TAContext.h
//  ThinkingSDK.default-Base-Core-Extension-Router-Util-iOS
//
//  Created by wwango on 2022/10/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAContext : NSObject

@property(nonatomic, strong) UIApplication *application;

@property(nonatomic, strong) NSDictionary *launchOptions;

+ (instancetype)shareInstance;

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName;

- (void)removeServiceWithServiceName:(NSString *)serviceName;

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName;

@end

NS_ASSUME_NONNULL_END
