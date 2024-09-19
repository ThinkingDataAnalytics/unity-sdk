//
//  TDAnalyticsAppGroupModel.h
//  ThinkingDataPushExtension
//
//  Created by 杨雄 on 2023/7/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalyticsAppGroupModel : NSObject
@property (nonatomic, copy) NSString *accountId;
@property (nonatomic, copy) NSString *distinctId;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *receiveUrl;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *eventCache;

- (instancetype)initWithAppId:(NSString *)appId dictionary:(NSDictionary *)dict;

- (NSDictionary *)jsonDict;

@end

NS_ASSUME_NONNULL_END
