//
//  TDApp.h
//  ThinkingDataCore
//
//  Created by 杨雄 on 2024/9/9.
//

#import <Foundation/Foundation.h>

#if __has_include(<ThinkingDataCore/TDSettings.h>)
#import <ThinkingDataCore/TDSettings.h>
#else
#import "TDSettings.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDApp : NSObject

/// Initializes from a local file, named 'td_settings.json'
+ (void)start;

/// Initializes with app id and server url
/// - Parameters:
///   - appId: The app id of your TE project
///   - serverUrl: The server url of your TE project
+ (void)startWithAppId:(NSString *)appId serverUrl:(NSString *)serverUrl;

/// Initializes with SDK config
/// - Parameter settings: More specific profile
+ (void)startWithSetting:(TDSettings *)settings;

@end

NS_ASSUME_NONNULL_END
