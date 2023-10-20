//
//  TDAPPPushParams.h
//  ThinkingSDK
//
//  Created by Charles on 6.5.23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern id __td_get_userNotificationCenter(void);
extern id __td_get_userNotificationCenter_delegate(void);
extern NSDictionary * __td_get_userNotificationCenterResponse(id response);
extern NSString * __td_get_userNotificationCenterRequestContentTitle(id response);
extern NSString * __td_get_userNotificationCenterRequestContentBody(id response);

NS_ASSUME_NONNULL_END
