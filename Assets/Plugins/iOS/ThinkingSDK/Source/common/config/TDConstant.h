//
//  TDConstant.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
Debug 模式

- ThinkingAnalyticsDebugOff : 默认不开启 Debug 模式
*/
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsDebugMode) {
    /**
     默认不开启 Debug 模式
     */
    ThinkingAnalyticsDebugOff      = 0,
    
    /**
     开启 DebugOnly 模式，不入库
     */
    ThinkingAnalyticsDebugOnly     = 1 << 0,
    
    /**
     开启 Debug 模式，并入库
     */
    ThinkingAnalyticsDebug         = 1 << 1,
    
    /**
     开启 Debug 模式，并入库，等同于 ThinkingAnalyticsDebug
     [兼容swift] swift 调用 oc 中的枚举类型，需要遵守 [枚举类型名+枚举值] 的规则。
     */
    ThinkingAnalyticsDebugOn = ThinkingAnalyticsDebug,
};

/**
 证书验证模式
*/
typedef NS_OPTIONS(NSInteger, TDSSLPinningMode) {
    /**
     默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证
    */
    TDSSLPinningModeNone          = 0,
    
    /**
     校验证书的公钥
    */
    TDSSLPinningModePublicKey     = 1 << 0,
    
    /**
     校验证书的所有内容
    */
    TDSSLPinningModeCertificate   = 1 << 1
};

/**
 自定义 HTTPS 认证
*/
typedef NSURLSessionAuthChallengeDisposition (^TDURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *_Nullable session, NSURLAuthenticationChallenge *_Nullable challenge, NSURLCredential *_Nullable __autoreleasing *_Nullable credential);



/**
 Log 级别

 - TDLoggingLevelNone : 默认不开启
 */
typedef NS_OPTIONS(NSInteger, TDLoggingLevel) {
    /**
     默认不开启
     */
    TDLoggingLevelNone  = 0,
    
    /**
     Error Log
     */
    TDLoggingLevelError = 1 << 0,
    
    /**
     Info  Log
     */
    TDLoggingLevelInfo  = 1 << 1,
    
    /**
     Debug Log
     */
    TDLoggingLevelDebug = 1 << 2,
};

/**
 上报数据网络条件

 - TDNetworkTypeDefault : 默认 3G、4G、WIFI
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    
    /**
     默认 3G、4G、WIFI
     */
    TDNetworkTypeDefault  = 0,
    
    /**
     仅WIFI
     */
    TDNetworkTypeOnlyWIFI = 1 << 0,
    
    /**
     2G、3G、4G、WIFI
     */
    TDNetworkTypeALL      = 1 << 1,
};

/**
 自动采集事件

 - ThinkingAnalyticsEventTypeNone           : 默认不开启自动埋点
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    
    /**
     默认不开启自动埋点
     */
    ThinkingAnalyticsEventTypeNone          = 0,
    
    /*
     APP 启动或从后台恢复事件
     */
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,
    
    /**
     APP 进入后台事件
     */
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,
    
    /**
     APP 控件点击事件
     */
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,
    
    /**
     APP 浏览页面事件
     */
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,
    
    /**
     APP 崩溃信息
     */
    ThinkingAnalyticsEventTypeAppViewCrash  = 1 << 4,
    
    /**
     APP 安装之后的首次打开
     */
    ThinkingAnalyticsEventTypeAppInstall    = 1 << 5,
    /**
     以上全部 APP 事件
     */
    ThinkingAnalyticsEventTypeAll    = ThinkingAnalyticsEventTypeAppStart | ThinkingAnalyticsEventTypeAppEnd | ThinkingAnalyticsEventTypeAppClick | ThinkingAnalyticsEventTypeAppInstall | ThinkingAnalyticsEventTypeAppViewCrash | ThinkingAnalyticsEventTypeAppViewScreen

};

typedef NS_OPTIONS(NSInteger, ThinkingNetworkType) {
    ThinkingNetworkTypeNONE     = 0,
    ThinkingNetworkType2G       = 1 << 0,
    ThinkingNetworkType3G       = 1 << 1,
    ThinkingNetworkType4G       = 1 << 2,
    ThinkingNetworkTypeWIFI     = 1 << 3,
    ThinkingNetworkType5G       = 1 << 4,
    ThinkingNetworkTypeALL      = 0xFF,
};

