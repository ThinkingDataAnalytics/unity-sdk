//
//  TDAnalytics+WebView.h
//  ThinkingSDK
//
//  Created by 杨雄 on 2023/8/17.
//

#if __has_include(<ThinkingSDK/TDAnalytics.h>)
#import <ThinkingSDK/TDAnalytics.h>
#else
#import "TDAnalytics.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TDAnalytics (WebView)

/// H5 is connected with the native APP SDK and used in conjunction with the addWebViewUserAgent interface
/// @param webView webView
/// @param request NSURLRequest request
/// @return YES：Process this request NO: This request has not been processed
+ (BOOL)showUpWebView:(id)webView withRequest:(NSURLRequest *)request;

/// When connecting data with H5, you need to call this interface to configure UserAgent
+ (void)addWebViewUserAgent;

/// H5 is connected with the native APP SDK and used in conjunction with the addWebViewUserAgent interface
/// @param webView webView
/// @param request NSURLRequest request
/// @param appId appId
/// @return YES：Process this request NO: This request has not been processed
+ (BOOL)showUpWebView:(id)webView withRequest:(NSURLRequest *)request withAppId:(NSString * _Nullable)appId;

@end

NS_ASSUME_NONNULL_END
