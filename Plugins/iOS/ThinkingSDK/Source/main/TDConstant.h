//
//  TDConstant.h
//  ThinkingSDK
//
//  Created by LiHuanan on 2020/9/8.
//  Copyright © 2020 thinkingdata. All rights reserved.
//

#import <Foundation/Foundation.h>

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
     Warning Log
     */
    TDLoggingLevelWarning = 1 << 1,
    
    /**
     Info  Log
     */
    TDLoggingLevelInfo  = 1 << 2,
    
    /**
     Debug Log
     */
    TDLoggingLevelDebug = 1 << 3,
};

/**
Debug Mode

- ThinkingAnalyticsDebugOff : Not enabled by default
*/
__attribute__((deprecated("This class is deprecated. Use the newClass instead: TDMode")))
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
Debug Mode

- ThinkingAnalyticsDebugOff : Not enabled by default
*/
typedef NS_OPTIONS(NSInteger, TDMode) {
    /**
     Not enabled by default
     */
    TDModeNormal      = 0,
    
    /**
     Enable DebugOnly Mode, Data is not persisted
     */
    TDModeDebugOnly     = 1 << 0,
    
    /**
     Enable Debug Mode，Data will persist
     */
    TDModeDebug         = 1 << 1,
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
__attribute__((deprecated("This class is deprecated. Use the newClass instead: TDReportingNetworkType")))
typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsNetworkType) {
    
    /**
     only WIFI
     */
    TDNetworkTypeOnlyWIFI = 1 << 0,
    
    /**
     2G、3G、4G、WIFI
     */
    TDNetworkTypeALL      = 1 << 1,
    
    /**
     3G、4G、WIFI
     */
    TDNetworkTypeDefault  = TDNetworkTypeALL,
};

typedef NS_OPTIONS(NSInteger, TDReportingNetworkType) {
    TDReportingNetworkTypeWIFI = 1 << 0,
    TDReportingNetworkTypeALL = 1 << 1,
};

/**
 Auto-Tracking Enum

 - ThinkingAnalyticsEventTypeNone           : auto-tracking is not enabled by default
 */
__attribute__((deprecated("This class is deprecated. Use the newClass instead: TDAutoTrackEventType")))
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


typedef NS_OPTIONS(NSInteger, TDThirdPartyType) {
    TDThirdPartyTypeNone               = 0,
    TDThirdPartyTypeAppsFlyer          = 1 << 0,
    TDThirdPartyTypeIronSource         = 1 << 1,
    TDThirdPartyTypeAdjust             = 1 << 2,
    TDThirdPartyTypeBranch             = 1 << 3,
    TDThirdPartyTypeTopOn              = 1 << 4,
    TDThirdPartyTypeTracking           = 1 << 5,
    TDThirdPartyTypeTradPlus           = 1 << 6,
    TDThirdPartyTypeAppLovin           = 1 << 7,
    TDThirdPartyTypeKochava            = 1 << 8,
    TDThirdPartyTypeTalkingData        = 1 << 9,
    TDThirdPartyTypeFirebase           = 1 << 10,
};

__attribute__((deprecated("This class is deprecated. Use the newClass instead: TDThirdPartyType")))
typedef NS_OPTIONS(NSUInteger, TAThirdPartyShareType) {
    TAThirdPartyShareTypeNONE               = TDThirdPartyTypeNone,
    TAThirdPartyShareTypeAPPSFLYER          = TDThirdPartyTypeAppsFlyer,
    TAThirdPartyShareTypeIRONSOURCE         = TDThirdPartyTypeIronSource,
    TAThirdPartyShareTypeADJUST             = TDThirdPartyTypeAdjust,
    TAThirdPartyShareTypeBRANCH             = TDThirdPartyTypeBranch,
    TAThirdPartyShareTypeTOPON              = TDThirdPartyTypeTopOn,
    TAThirdPartyShareTypeTRACKING           = TDThirdPartyTypeTracking,
    TAThirdPartyShareTypeTRADPLUS           = TDThirdPartyTypeTradPlus,
    TAThirdPartyShareTypeAPPLOVIN           = TDThirdPartyTypeAppLovin,
    TAThirdPartyShareTypeKOCHAVA            = TDThirdPartyTypeKochava,
    TAThirdPartyShareTypeTALKINGDATA        = TDThirdPartyTypeTalkingData,
    TAThirdPartyShareTypeFIREBASE           = TDThirdPartyTypeFirebase,
    
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
typedef NS_ENUM(NSInteger, TDTrackStatus) {
    /// Suspend reporting
    TDTrackStatusPause,
    /// Stop reporting and clear cache
    TDTrackStatusStop,
    /// Suspend reporting and continue to persist data
    TDTrackStatusSaveOnly,
    /// reset normal
    TDTrackStatusNormal
};


//MARK: - Data reporting status
__attribute__((deprecated("This class is deprecated. Use the newClass instead: TDTrackStatus")))
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

//MARK: - DNS service
typedef NSString *TDDNSService NS_TYPED_EXTENSIBLE_ENUM;
static TDDNSService const _Nonnull TDDNSServiceCloudFlare = @"https://cloudflare-dns.com/dns-query?name=";
static TDDNSService const _Nonnull TDDNSServiceCloudALi = @"https://223.5.5.5/resolve?name=";
static TDDNSService const _Nonnull TDDNSServiceCloudGoogle = @"https://8.8.8.8/resolve?name=";

