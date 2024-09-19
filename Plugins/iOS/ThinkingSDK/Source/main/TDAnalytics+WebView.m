//
//  TDAnalytics+WebView.m
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#import "TDAnalytics+WebView.h"
#import "ThinkingAnalyticsSDKPrivate.h"

static NSString * const TA_JS_TRACK_SCHEME = @"thinkinganalytics://trackEvent";

@implementation TDAnalytics (WebView)

+ (BOOL)showUpWebView:(nonnull id)webView withRequest:(nonnull NSURLRequest *)request {
    NSString *appId = [ThinkingAnalyticsSDK defaultAppId];
    return [self showUpWebView:webView withRequest:request withAppId:appId];
}

+ (BOOL)showUpWebView:(id)webView withRequest:(NSURLRequest *)request withAppId:(NSString *)appId {
    if (webView == nil || request == nil || ![request isKindOfClass:NSURLRequest.class]) {
        return NO;
    }
    
    NSString *urlStr = request.URL.absoluteString;
    if (!urlStr) {
        return NO;
    }
    
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length == 0) {
        return NO;
    }
    
    NSString *query = [[request URL] query];
    NSArray *queryItem = [query componentsSeparatedByString:@"="];
    
    if (queryItem.count != 2)
        return YES;
    
    NSString *queryValue = [queryItem lastObject];
    if ([urlStr rangeOfString:TA_JS_TRACK_SCHEME].length > 0) {
        NSString *eventData = [queryValue stringByRemovingPercentEncoding];
        if (eventData.length > 0) {
            [TDAnalytics clickFromH5:eventData withAppId:appId];
        }
    }
    return YES;
}

+ (void)addWebViewUserAgent {
    void (^setUserAgent)(NSString *userAgent) = ^void (NSString *userAgent) {
        if ([userAgent rangeOfString:@"td-sdk-ios"].location == NSNotFound) {
            userAgent = [userAgent stringByAppendingString:@" /td-sdk-ios"];
            NSDictionary *userAgentDic = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:userAgentDic];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    };
    dispatch_block_t getUABlock = ^() {
        [TDAnalytics wkWebViewGetUserAgent:^(NSString *userAgent) {
            setUserAgent(userAgent);
        }];
    };
    td_dispatch_main_sync_safe(getUABlock);
}

// MARK: private

static WKWebView *_blankWebView = nil;
+ (void)wkWebViewGetUserAgent:(void(^)(NSString *))completion {
    if (!_blankWebView) {
        _blankWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    [_blankWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
        completion(userAgent);
    }];
}

+ (void)clickFromH5:(NSString *)data withAppId:(NSString *)appId {
    NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return;
    }
    
    NSError *err;
    NSDictionary *eventDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return;
    }
    
    ThinkingAnalyticsSDK *instance = nil;
    NSString *jsAppid = eventDict[@"#app_id"];
    if ([jsAppid isKindOfClass:[NSString class]]) {
        instance = [ThinkingAnalyticsSDK instanceWithAppid:jsAppid];
    }
    if (!instance) {
        instance = [ThinkingAnalyticsSDK instanceWithAppid:appId];
    }
    if (!instance) {
        return;
    }
    
    NSArray *dataArr = eventDict[@"data"];
    if (![dataArr isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSDictionary *dataInfo = dataArr.firstObject;
    if (dataInfo != nil) {
        NSString *type = [dataInfo objectForKey:@"#type"];
        NSString *event_name = [dataInfo objectForKey:@"#event_name"];
        NSString *time = [dataInfo objectForKey:@"#time"];
        NSDictionary *properties = [dataInfo objectForKey:@"properties"];
        
        NSString *extraID;
        
        if ([type isEqualToString:TD_EVENT_TYPE_TRACK]) {
            extraID = [dataInfo objectForKey:@"#first_check_id"];
            if (extraID) {
                type = TD_EVENT_TYPE_TRACK_FIRST;
            }
        } else {
            extraID = [dataInfo objectForKey:@"#event_id"];
        }
        
        NSMutableDictionary *dic = [properties mutableCopy];
        [dic removeObjectForKey:@"#account_id"];
        [dic removeObjectForKey:@"#distinct_id"];
        [dic removeObjectForKey:@"#device_id"];
        [dic removeObjectForKey:@"#lib"];
        [dic removeObjectForKey:@"#lib_version"];
        [dic removeObjectForKey:@"#screen_height"];
        [dic removeObjectForKey:@"#screen_width"];
        
        [self h5trackWithInstance:instance eventName:event_name extraID:extraID properties:dic type:type time:time];
    }
}

+ (void)h5trackWithInstance:(ThinkingAnalyticsSDK *)instance eventName:(NSString *)eventName extraID:(NSString *)extraID properties:(NSDictionary *)propertieDict type:(NSString *)type time:(NSString *)time {
    if ([ThinkingAnalyticsSDK isTrackEvent:type]) {
        TDTrackEvent *event = nil;
        if ([type isEqualToString:TD_EVENT_TYPE_TRACK]) {
            TDTrackEvent *trackEvent = [[TDTrackEvent alloc] initWithName:eventName];
            event = trackEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_FIRST]) {
            TDTrackFirstEvent *firstEvent = [[TDTrackFirstEvent alloc] initWithName:eventName];
            firstEvent.firstCheckId = extraID;
            event = firstEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_UPDATE]) {
            TDTrackUpdateEvent *updateEvent = [[TDTrackUpdateEvent alloc] initWithName:eventName];
            updateEvent.eventId = extraID;
            event = updateEvent;
        } else if ([type isEqualToString:TD_EVENT_TYPE_TRACK_OVERWRITE]) {
            TDTrackOverwriteEvent *overwriteEvent = [[TDTrackOverwriteEvent alloc] initWithName:eventName];
            overwriteEvent.eventId = extraID;
            event = overwriteEvent;
        }
        event.h5TimeString = time;
        if ([propertieDict objectForKey:@"#zone_offset"]) {
            event.h5ZoneOffSet = [propertieDict objectForKey:@"#zone_offset"];
        }
        [instance asyncTrackEventObject:event properties:propertieDict isH5:YES];
    } else {
        TDUserEvent *event = [[TDUserEvent alloc] initWithType:[TDBaseEvent typeWithTypeString:type]];
        [instance asyncUserEventObject:event properties:propertieDict isH5:YES];
    }
}

@end
