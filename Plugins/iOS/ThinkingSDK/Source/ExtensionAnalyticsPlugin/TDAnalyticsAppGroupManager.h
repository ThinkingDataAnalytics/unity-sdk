//
//  TDAnalyticsAppGroupManager.h
//  ThinkingSDK.default-TDCore-iOS
//
//  Created by 杨雄 on 2023/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalyticsAppGroupManager : NSObject
@property (nonatomic, copy) NSString * appGroupName;

+ (instancetype)shareInstance;

- (void)setAccountId:(NSString * _Nullable)accountId appId:(NSString *)appId;
- (void)setDistinctId:(NSString *)distinctId appId:(NSString *)appId;
- (void)setDeviceId:(NSString *)deviceId appId:(NSString *)appId;
- (void)setReceiveUrl:(NSString *)url appId:(NSString *)appId;

- (NSArray<NSDictionary *> * _Nullable)getExtensionEventCacheWithAppId:(NSString *)appId;
- (void)clearEventCacheWithAppId:(NSString *)appId;

@end

NS_ASSUME_NONNULL_END
