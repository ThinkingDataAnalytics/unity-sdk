#import "TDAnalyticsNetwork.h"

#if __has_include(<ThinkingDataCore/NSData+TDGzip.h>)
#import <ThinkingDataCore/NSData+TDGzip.h>
#else
#import "NSData+TDGzip.h"
#endif
#if __has_include(<ThinkingDataCore/TDJSONUtil.h>)
#import <ThinkingDataCore/TDJSONUtil.h>
#else
#import "TDJSONUtil.h"
#endif
#import "TDLogging.h"
#import "TDSecurityPolicy.h"
#import "TDAppState.h"

#if __has_include(<ThinkingDataCore/TDCoreDeviceInfo.h>)
#import <ThinkingDataCore/TDCoreDeviceInfo.h>
#else
#import "TDCoreDeviceInfo.h"
#endif

#if TARGET_OS_IOS
#import "TDToastView.h"
#endif

static NSString *kTAIntegrationType = @"TA-Integration-Type";
static NSString *kTAIntegrationVersion = @"TA-Integration-Version";
static NSString *kTAIntegrationCount = @"TA-Integration-Count";
static NSString *kTAIntegrationExtra = @"TA-Integration-Extra";
static NSString *kTADatasType = @"TA-Datas-Type";

static NSTimeInterval g_lastQueryDNSTime = 0;
static dispatch_queue_t g_queryDNSQueue = nil;
static NSArray<TDDNSService> *g_dnsServices =  nil;
static NSMutableDictionary<NSString *, NSString *> *g_dnsIpMap = nil;

@interface TDAnalyticsNetwork ()

@property (atomic, assign) BOOL dnsServiceDegrade;

@end

@implementation TDAnalyticsNetwork

- (NSURLSession *)sharedURLSession {
    static dispatch_once_t onceToken;
    static NSURLSession *sharedSession = nil;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sharedSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    });
    return sharedSession;
}

- (NSString *)URLEncode:(NSString *)string {
    NSString *encodedString = [string stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "] invertedSet]];
    return encodedString;
}

- (int)flushDebugEvents:(NSDictionary *)record appid:(NSString *)appid isDebugOnly:(BOOL)isDebugOnly {
    __block int debugResult = -1;
    NSString *jsonString = [TDJSONUtil JSONStringForObject:record];
    NSMutableURLRequest *request = [self buildDebugRequestWithJSONString:jsonString appid:appid deviceId:[TDCoreDeviceInfo deviceId] isDebugOnly:isDebugOnly];
    dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);

    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            debugResult = -2;
            TDLogError(@"Debug Networking error:%@", error);
            [self callbackNetworkErrorWithRequest:jsonString error:error.debugDescription];
            dispatch_semaphore_signal(flushSem);
            return;
        }
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] == 200) {
            NSError *err;
            
            if (!data) {
                dispatch_semaphore_signal(flushSem);
                return;
            }
            
            NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            TDLogDebug(@"Send event, Response = %@", retDic);

            if (err) {
                TDLogError(@"Debug data json error:%@", err);
                debugResult = -2;
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                debugResult = 1;
                NSArray* errorProperties = [retDic objectForKey:@"errorProperties"];
                NSMutableString *errorStr = [NSMutableString string];
                for (id obj in errorProperties) {
                    NSString *errorReasons = [obj objectForKey:@"errorReason"];
                    NSString *propertyName = [obj objectForKey:@"propertyName"];
                    [errorStr appendFormat:@" propertyName:%@ errorReasons:%@\n", propertyName, errorReasons];
                }
                TDLogError(@"Debug data error:%@", errorStr);
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:2]]) {
                debugResult = 2;
                NSString *errorReasons = [[retDic objectForKey:@"errorReasons"] componentsJoinedByString:@" "];
                TDLogError(@"Debug data error:%@", errorReasons);
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                debugResult = 0;
                TDLogDebug(@"Verify data success.");
            } else if ([[retDic objectForKey:@"errorLevel"] isEqualToNumber:[NSNumber numberWithInt:-1]]) {
                debugResult = -1;
                NSString *errorReasons = [[retDic objectForKey:@"errorReasons"] componentsJoinedByString:@" "];
                TDLogError(@"Debug mode error:%@", errorReasons);
            }
            
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                if (debugResult == 0 || debugResult == 1 || debugResult == 2) {
#if TARGET_OS_IOS
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIApplication *application = [TDAppState sharedApplication];
                        if (![application isKindOfClass:UIApplication.class]) {
                            return;
                        }
                        UIWindow *window = application.keyWindow;
                        [TDToastView showInWindow:window text:[NSString stringWithFormat:@"The current mode is:%@", isDebugOnly ? @"DebugOnly(Data is not persisted) \n The test joint debugging stage is allowed to open \n Please turn off the Debug function before the official launch" : @"Debug"] duration:2.0];
                    });
#endif
                }
            });
            
            @try {
                if ([retDic isKindOfClass:[NSDictionary class]]) {
                    if ([[(NSDictionary *)retDic objectForKey:@"errorLevel"] integerValue] != 0) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:retDic options:NSJSONWritingPrettyPrinted error:NULL];
                        NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self callbackNetworkErrorWithRequest:jsonString error:string];
                    }
                }
            } @catch (NSException *exception) {
                
            }
        } else {
            if ([TDAnalyticsNetwork isEnableDNS]) {
                self.dnsServiceDegrade = YES;
            }
            debugResult = -2;
            NSString *urlResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            TDLogError(@"%@", [NSString stringWithFormat:@"Debug %@ network failed with response '%@'.", self, urlResponse]);
            [self callbackNetworkErrorWithRequest:jsonString error:urlResponse];
        }
        dispatch_semaphore_signal(flushSem);
    };

    NSURLSessionDataTask *task = [[self sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    TDLogDebug(@"Send event. %@\nRequest = %@", request.URL.absoluteString, record);
    [task resume];

    dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    return debugResult;
}

- (BOOL)flushEvents:(NSArray<NSDictionary *> *)recordArray {
    __block BOOL flushSucc = YES;
    UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSDictionary *flushDic = @{
        @"data": recordArray,
        @"#app_id": self.appid,
        @"#flush_time": @(time),
    };
    
    __block BOOL isEncrypt;
    [recordArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.allKeys containsObject:@"ekey"]) {
            isEncrypt = YES;
            *stop = YES;
        }
    }];
    
    NSString *jsonString = [TDJSONUtil JSONStringForObject:flushDic];
    NSMutableURLRequest *request = [self buildRequestWithJSONString:jsonString];
    [request addValue:[TDDeviceInfo sharedManager].libName forHTTPHeaderField:kTAIntegrationType];
    [request addValue:[TDDeviceInfo sharedManager].libVersion forHTTPHeaderField:kTAIntegrationVersion];
    [request addValue:@(recordArray.count).stringValue forHTTPHeaderField:kTAIntegrationCount];
    [request addValue:@"iOS" forHTTPHeaderField:kTAIntegrationExtra];
    if (isEncrypt) {
        [request addValue:@"1" forHTTPHeaderField:kTADatasType];
    }
//    [request addValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
//    [request addValue:@"timeout=15,max=100" forHTTPHeaderField:@"Keep-Alive"];
    
    dispatch_semaphore_t flushSem = dispatch_semaphore_create(0);

    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            flushSucc = NO;
            TDLogError(@"Networking error:%@", error);
            [self callbackNetworkErrorWithRequest:jsonString error:error.debugDescription];
            dispatch_semaphore_signal(flushSem);
            return;
        }

        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if ([urlResponse statusCode] == 200) {
            flushSucc = YES;
            if (!data) {
                dispatch_semaphore_signal(flushSem);
                return;
            }
            id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            TDLogDebug(@"Send event, Response = %@", result);
            
            @try {
                if ([result isKindOfClass:[NSDictionary class]]) {
                    if ([[(NSDictionary *)result objectForKey:@"code"] integerValue] != 0) {
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:NULL];
                        NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        [self callbackNetworkErrorWithRequest:jsonString error:string];
                    }
                }
            } @catch (NSException *exception) {
                
            }

        } else {
            flushSucc = NO;
            if ([TDAnalyticsNetwork isEnableDNS]) {
                self.dnsServiceDegrade = YES;
            }
            NSString *urlResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            TDLogError(@"%@", [NSString stringWithFormat:@"%@ network failed with response '%@'.", self, urlResponse]);
            [self callbackNetworkErrorWithRequest:jsonString error:urlResponse];
        }

        dispatch_semaphore_signal(flushSem);
    };

    NSURLSessionDataTask *task = [[self sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    TDLogDebug(@"Send event. %@\nRequest = %@", request.URL.absoluteString, flushDic);
    [task resume];
    dispatch_semaphore_wait(flushSem, DISPATCH_TIME_FOREVER);
    return flushSucc;
}

+ (void)enableDNSServcie:(NSArray<TDDNSService> *)services {
    @synchronized (TDAnalyticsNetwork.class) {
        g_dnsServices = [services copy];
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_queryDNSQueue = dispatch_queue_create("cn.thinkingdata.analytics.queryDNS", DISPATCH_QUEUE_SERIAL);
    });
}

+ (BOOL)isEnableDNS {
    BOOL result = NO;
    @synchronized (TDAnalyticsNetwork.class) {
        if (g_dnsServices.count > 0) {
            result = YES;
        }
    }
    return result;
}

- (void)fetchIPMap {
    [self getDNSIps];
}

- (void)callbackNetworkErrorWithRequest:(NSString *)request error:(NSString *)error {
    if (request == nil && error == nil) return;
    
    ThinkingAnalyticsSDK *tdSDK = [ThinkingAnalyticsSDK instanceWithAppid:self.appid];
    if (tdSDK.errorCallback) {
        NSInteger code = 10001;
        NSString *errorMsg = error;
        NSString *ext = request;
        tdSDK.errorCallback(code, errorMsg, ext);
    }
}

- (NSMutableURLRequest *)buildRequestWithJSONString:(NSString *)jsonString {
    NSData *zippedData = [NSData td_gzipData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *postBody = [zippedData base64EncodedStringWithOptions:0];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self formatURLWithOriginalUrl:self.serverURL]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *contentType = [NSString stringWithFormat:@"text/plain"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60.0];
    return request;
}

- (NSURL *)formatURLWithOriginalUrl:(NSURL *)url {
    if (!url) {
        return nil;
    }
    @synchronized (TDAnalyticsNetwork.class) {
        if (!g_dnsServices || g_dnsServices.count <= 0) {
            return url;
        }
    }
    if (self.dnsServiceDegrade) {
        return url;
    }
    NSString *ipStr = nil;
    @synchronized (TDAnalyticsNetwork.class) {
        ipStr = [g_dnsIpMap objectForKey:url.host];
    }
    if ([ipStr isKindOfClass:NSString.class] && ipStr.length > 0) {
        NSString *ipUrlString = [NSString stringWithFormat:@"%@://%@%@", url.scheme, ipStr, url.path];
        NSURL *serverUrl = [NSURL URLWithString:ipUrlString] ?: url;
        return serverUrl;
    } else {
        [self getDNSIps];
        return url;
    }
}

- (NSMutableURLRequest *)buildDebugRequestWithJSONString:(NSString *)jsonString appid:(NSString *)appid deviceId:(NSString *)deviceId isDebugOnly:(BOOL)isDebugOnly {
    // dryRun=0, if the verification is passed, it will be put into storage. dryRun=1, no storage
    int dryRun = isDebugOnly ? 1 : 0;
    NSString *appendParams = [NSString stringWithFormat:@"appid=%@&source=client&dryRun=%d&deviceId=%@", appid, dryRun, deviceId];
    TDLogDebug(@"RequestAppendParams: %@", appendParams);
    NSString *postData = [NSString stringWithFormat:@"%@&data=%@", appendParams, [self URLEncode:jsonString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self formatURLWithOriginalUrl:self.serverDebugURL]];
    [request setHTTPMethod:@"POST"];
    request.HTTPBody = [postData dataUsingEncoding:NSUTF8StringEncoding];
    return request;
}

- (void)fetchRemoteConfig:(NSString *)appid handler:(TDFlushConfigBlock)handler {
    void (^block)(NSData *, NSURLResponse *, NSError *) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
            TDLogError(@"Get remote config failed:%@", error);
            return;
        }
        NSError *err;
        if (!data) {
            return;
        }
        NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (err) {
            TDLogError(@"Get remote config error:%@", err);
        } else if ([ret isKindOfClass:[NSDictionary class]] && [ret[@"code"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            TDLogInfo(@"Get remote config for %@ : %@", appid, [ret objectForKey:@"data"]);
            handler([ret objectForKey:@"data"], error);
        } else {
            TDLogError(@"Get remote config failed");
        }
    };
    NSString *urlStr = [NSString stringWithFormat:@"%@?appid=%@", self.serverURL, appid];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"Get"];
    NSURLSessionDataTask *task = [[self sharedURLSession] dataTaskWithRequest:request completionHandler:block];
    [task resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;

    NSString *domain = challenge.protectionSpace.host;
    
    if ([TDAnalyticsNetwork isEnableDNS]) {
        // is IP or not
        if (![self.serverURL.host isEqualToString:domain] && ![self isDomainInDNSService:domain]) {
            domain = [self getOriginHostWithIp:domain];
            if (domain == nil) {
                domain = self.serverURL.host;
            }
        }
    }
    
    if (self.sessionDidReceiveAuthenticationChallenge) {
        disposition = self.sessionDidReceiveAuthenticationChallenge(session, challenge, &credential);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:domain]) {
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    }

    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)getDNSIps {
    NSArray<TDDNSService> *dnsServices = nil;
    @synchronized (TDAnalyticsNetwork.class) {
        if (!g_dnsServices || g_dnsServices.count <= 0) {
            return;
        }
        dnsServices = [g_dnsServices copy];
        // Throttle DNS network query. Period is 30s
        NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
        if (nowTimeInterval - g_lastQueryDNSTime <= 30) {
            return;
        } else {
            g_lastQueryDNSTime = nowTimeInterval;
        }
    }
    NSString *serverHost = [self.serverURL host];
    dispatch_async(g_queryDNSQueue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        TDLogDebug(@"Parse DNS request is begining ...");
        for (TDDNSService dnsServiceUrl in dnsServices) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", dnsServiceUrl, serverHost]];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"GET"];
            [request addValue:@"application/dns-json" forHTTPHeaderField:@"accept"];
            [request setTimeoutInterval:6];
            __block BOOL result = NO;
            NSURLSessionDataTask *task = [[self sharedURLSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error == nil && data != nil && data.length > 0) {
                    NSError *jsonError = nil;
                    NSDictionary *dnsResult = nil;
                    @try {
                        dnsResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                    } @catch (NSException *exception) {
                        
                    }
                    if (jsonError == nil && [dnsResult isKindOfClass:NSDictionary.class]) {
                        NSString *ipStr = nil;
                        NSArray *answer = [dnsResult objectForKey:@"Answer"];
                        if (answer && [answer isKindOfClass:[NSArray class]]) {
                            NSDictionary *dnsObj = [answer lastObject];
                            if (dnsObj && [dnsObj isKindOfClass:[NSDictionary class]]) {
                                ipStr = [dnsObj objectForKey:@"data"];
                            }
                        }
                        if (ipStr && [ipStr isKindOfClass:[NSString class]]) {
                            result = YES;
                            @synchronized (TDAnalyticsNetwork.class) {
                                if (g_dnsIpMap == nil) {
                                    g_dnsIpMap = [NSMutableDictionary dictionary];
                                }
                                [g_dnsIpMap setObject:ipStr forKey:serverHost];
                            }
                        }
                    }
                } else {
                    TDLogError(@"Parse DNS error: %@", error.localizedDescription);
                }
                dispatch_semaphore_signal(semaphore);
            }];
            TDLogDebug(@"Parse DNS request: %@", request.URL.absoluteString);
            [task resume];
            dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)));
            TDLogDebug(@"Parse DNS response: %@. Service url: %@", result ? @"success" : @"failed", request.URL.absoluteString);
            if (result) {
                @synchronized (TDAnalyticsNetwork.class) {
                    TDLogDebug(@"Parse DNS is end. %@", g_dnsIpMap);
                }
                break;
            }
        }
    });
}

- (BOOL)isDomainInDNSService:(NSString *)domain {
    NSArray<TDDNSService> *dNSServices = @[TDDNSServiceCloudFlare, TDDNSServiceCloudALi, TDDNSServiceCloudGoogle];
    for (TDDNSService dnsServiceUrl in dNSServices) {
        if ([dnsServiceUrl containsString:domain]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getOriginHostWithIp:(NSString *)ip {
    if ([ip isKindOfClass:NSString.class] && ip.length <= 0) {
        return nil;
    }
    __block NSString *originHost = nil;
    @synchronized (TDAnalyticsNetwork.class) {
        [g_dnsIpMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSString class]] && [obj containsString:ip]) {
                originHost = key;
                *stop = YES;
            }
        }];
    }
    return originHost;
}

@end
