//
//  TDAnalyticsAppGroupModel.m
//  ThinkingDataPushExtension
//
//  Created by 杨雄 on 2023/7/10.
//

#import "TDAnalyticsAppGroupModel.h"

static NSString * const kTDAppGroupAccountId = @"accountId";
static NSString * const kTDAppGroupDistinctId = @"distinctId";
static NSString * const kTDAppGroupDeviceId = @"deviceId";
static NSString * const kTDAppGroupReceiveUrl = @"receiveUrl";
static NSString * const kTDAppGroupEventCache = @"extension_event_cache";

@interface TDAnalyticsAppGroupModel ()

@end

@implementation TDAnalyticsAppGroupModel

- (instancetype)initWithAppId:(NSString *)appId dictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        NSString *receiverUrl = dict[kTDAppGroupReceiveUrl];
        if (!(receiverUrl.length && appId.length)) {
            return nil;
        }
        self.appId = appId;
        self.receiveUrl = receiverUrl;
        
        if (!(dict && [dict isKindOfClass:NSDictionary.class])) {
            return nil;
        }
        
        NSString *accountID = dict[kTDAppGroupAccountId];
        if (accountID && [accountID isKindOfClass:NSString.class]) {
            self.accountId = accountID;
        }
        NSString *distinctId = dict[kTDAppGroupDistinctId];
        if (distinctId && [distinctId isKindOfClass:NSString.class]) {
            self.distinctId = distinctId;
        }
        NSString *deviceId = dict[kTDAppGroupDeviceId];
        if (deviceId && [deviceId isKindOfClass:NSString.class]) {
            self.deviceId = deviceId;
        }
        NSArray *eventCache = dict[kTDAppGroupEventCache];
        if (eventCache && [eventCache isKindOfClass:NSArray.class]) {
            self.eventCache = [eventCache mutableCopy];
        } else {
            eventCache = [NSMutableArray array];
        }
    }
    return self;
}

- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[kTDAppGroupReceiveUrl] = self.receiveUrl;
    if (self.accountId) {
        dict[kTDAppGroupAccountId] = self.accountId;
    }
    if (self.distinctId) {
        dict[kTDAppGroupDistinctId] = self.distinctId;
    }
    if (self.deviceId) {
        dict[kTDAppGroupDeviceId] = self.deviceId;
    }
    if (self.eventCache) {
        dict[kTDAppGroupEventCache] = self.eventCache;
    }
    return dict;
}

@end
