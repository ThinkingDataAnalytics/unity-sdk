//
//  TDConstant.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
Debug Mode

- ThinkingAnalyticsDebugOff : Not enabled by default
*/
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsDebugMode) {
    /**
     Not enabled by default
     */
    ThinkingAnalyticsDebugOff      = 0,
    
    /**
     Enable DebugOnly Mode, Data is not persisted
     */
    ThinkingAnalyticsDebugOnly     = 1 << 0,
    
    /**
     Enable Debug Mode，Data will persist
     */
    ThinkingAnalyticsDebug         = 1 << 1,
    
    /**
     Enable Debug Mode，Data will persist，Equivalent to ThinkingAnalyticsDebug
     */
    ThinkingAnalyticsDebugOn = ThinkingAnalyticsDebug,
};


/**
 Log Level

 - TDLoggingLevelNone : Not enabled by default
 */
typedef NS_OPTIONS(NSInteger, TDLoggingLevel) {
    /**
     Not enabled by default
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
 Https Certificate Verification Mode
*/
typedef NS_OPTIONS(NSInteger, TDSSLPinningMode) {
    /**
     The default authentication method will only verify the certificate returned by the server in the system's trusted certificate list
    */
    TDSSLPinningModeNone          = 0,
    
    /**
     The public key of the verification certificate
    */
    TDSSLPinningModePublicKey     = 1 << 0,
    
    /**
     Verify all contents of the certificate
    */
    TDSSLPinningModeCertificate   = 1 << 1
};

/**
 Custom HTTPS Authentication
*/
typedef NSURLSessionAuthChallengeDisposition (^TDURLSessionDidReceiveAuthenticationChallengeBlock)(NSURLSession *_Nullable session, NSURLAuthenticationChallenge *_Nullable challenge, NSURLCredential *_Nullable __autoreleasing *_Nullable credential);



/**
 Network Type Enum

 - TDNetworkTypeDefault :  3G、4G、WIFI
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    
    /**
     3G、4G、WIFI
     */
    TDNetworkTypeDefault  = 0,
    
    /**
     only WIFI
     */
    TDNetworkTypeOnlyWIFI = 1 << 0,
    
    /**
     2G、3G、4G、WIFI
     */
    TDNetworkTypeALL      = 1 << 1,
};

/**
 Auto-Tracking Enum

 - ThinkingAnalyticsEventTypeNone           : auto-tracking is not enabled by default
 */
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsAutoTrackEventType) {
    
    /**
     auto-tracking is not enabled by default
     */
    ThinkingAnalyticsEventTypeNone          = 0,
    
    /*
     Active Events
     */
    ThinkingAnalyticsEventTypeAppStart      = 1 << 0,
    
    /**
     Inactive Events
     */
    ThinkingAnalyticsEventTypeAppEnd        = 1 << 1,
    
    /**
     Clicked events
     */
    ThinkingAnalyticsEventTypeAppClick      = 1 << 2,
    
    /**
     View Page Events
     */
    ThinkingAnalyticsEventTypeAppViewScreen = 1 << 3,
    
    /**
     Crash Events
     */
    ThinkingAnalyticsEventTypeAppViewCrash  = 1 << 4,
    
    /**
     Installation Events
     */
    ThinkingAnalyticsEventTypeAppInstall    = 1 << 5,
    /**
     All  Events
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


typedef NS_OPTIONS(NSInteger, TAThirdPartyShareType) {
    TAThirdPartyShareTypeNONE               = 0,
    TAThirdPartyShareTypeAPPSFLYER          = 1 << 0,
    TAThirdPartyShareTypeIRONSOURCE         = 1 << 1,
    TAThirdPartyShareTypeADJUST             = 1 << 2,
    TAThirdPartyShareTypeBRANCH             = 1 << 3,
    TAThirdPartyShareTypeTOPON              = 1 << 4,
    TAThirdPartyShareTypeTRACKING           = 1 << 5,
    TAThirdPartyShareTypeTRADPLUS           = 1 << 6,
    TAThirdPartyShareTypeAPPLOVIN           = 1 << 7,
    TAThirdPartyShareTypeKOCHAVA            = 1 << 8,
    TAThirdPartyShareTypeTALKINGDATA        = 1 << 9,
    TAThirdPartyShareTypeFIREBASE           = 1 << 10,
    
    
    TDThirdPartyShareTypeNONE               = TAThirdPartyShareTypeNONE,
    TDThirdPartyShareTypeAPPSFLYER          = TAThirdPartyShareTypeAPPSFLYER,
    TDThirdPartyShareTypeIRONSOURCE         = TAThirdPartyShareTypeIRONSOURCE,
    TDThirdPartyShareTypeADJUST             = TAThirdPartyShareTypeADJUST,
    TDThirdPartyShareTypeBRANCH             = TAThirdPartyShareTypeBRANCH,
    TDThirdPartyShareTypeTOPON              = TAThirdPartyShareTypeTOPON,
    TDThirdPartyShareTypeTRACKING           = TAThirdPartyShareTypeTRACKING,
    TDThirdPartyShareTypeTRADPLUS           = TAThirdPartyShareTypeTRADPLUS,
    
};

//MARK: - Data reporting status
typedef NS_ENUM(NSInteger, TATrackStatus) {
    /// Suspend reporting
    TATrackStatusPause,
    /// Stop reporting and clear cache
    TATrackStatusStop,
    /// Suspend reporting and continue to persist data
    TATrackStatusSaveOnly,
    /// reset normal
    TATrackStatusNormal
};
