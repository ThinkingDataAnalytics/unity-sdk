#import "ThinkingExceptionHandler.h"

#include <libkern/OSAtomic.h>
#include <stdatomic.h>
#import "TDLogging.h"

static NSString * const TDUncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString * const TDUncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
static int TDSignals[] = {SIGILL, SIGABRT, SIGBUS, SIGSEGV, SIGFPE, SIGPIPE, SIGTRAP};
static volatile atomic_int_fast32_t TDExceptionCount = 0;
static const atomic_int_fast32_t TDExceptionMaximum = 9;

@implementation ThinkingExceptionHandler

+ (instancetype)sharedHandler {
    static ThinkingExceptionHandler *gSharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gSharedHandler = [[ThinkingExceptionHandler alloc] init];
    });
    return gSharedHandler;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _thinkingAnalyticsSDKInstances = [NSHashTable weakObjectsHashTable];
        _td_signalHandlers = calloc(NSIG, sizeof(struct sigaction));
        [self setupHandlers];
    }
    return self;
}

- (void)setupHandlers {
    _td_lastExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&TDHandleException);
    
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_SIGINFO;
    action.sa_sigaction = &TDSignalHandler;
    for (int i = 0; i < sizeof(TDSignals) / sizeof(int); i++) {
        struct sigaction prev_action;
        int err = sigaction(TDSignals[i], &action, &prev_action);
        if (err == 0) {
            memcpy(_td_signalHandlers + TDSignals[i], &prev_action, sizeof(prev_action));
        } else {
            TDLogError(@"Error Signal: %d", TDSignals[i]);
        }
    }
}

static void TDHandleException(NSException *exception) {
    ThinkingExceptionHandler *handler = [ThinkingExceptionHandler sharedHandler];

    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&TDExceptionCount, 1, memory_order_relaxed);
    if (exceptionCount <= TDExceptionMaximum) {
        [handler td_handleUncaughtException:exception];
    }
    if (handler.td_lastExceptionHandler) {
        handler.td_lastExceptionHandler(exception);
    }
}

static void TDSignalHandler(int signalNumber, struct __siginfo *info, void *context) {
    ThinkingExceptionHandler *handler = [ThinkingExceptionHandler sharedHandler];
    NSMutableDictionary *crashInfo;
    NSString *reason;
    NSException *exception;
    
    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&TDExceptionCount, 1, memory_order_relaxed);
    if (exceptionCount <= TDExceptionMaximum) {
        [crashInfo setObject:[NSNumber numberWithInt:signalNumber] forKey:TDUncaughtExceptionHandlerSignalKey];
        reason = [NSString stringWithFormat:@"Signal %d was raised.", signalNumber];
        exception = [NSException exceptionWithName:TDUncaughtExceptionHandlerSignalExceptionName reason:reason userInfo:crashInfo];
        [handler td_handleUncaughtException:exception];
    }
    
    struct sigaction prev_action = handler.td_signalHandlers[signalNumber];
    if (prev_action.sa_handler == SIG_DFL) {
        signal(signalNumber, SIG_DFL);
        raise(signalNumber);
        return;
    }
    if (prev_action.sa_flags & SA_SIGINFO) {
        if (prev_action.sa_sigaction) {
            prev_action.sa_sigaction(signalNumber, info, context);
        }
    } else if (prev_action.sa_handler) {
        prev_action.sa_handler(signalNumber);
    }
}


- (void)td_handleUncaughtException:(NSException *)exception {

    NSDate *trackDate = [NSDate date];
    NSDictionary *dic = [self td_getCrashInfo:exception];
    for (ThinkingAnalyticsSDK *instance in self.thinkingAnalyticsSDKInstances) {
        [instance autotrack:TD_APP_CRASH_EVENT properties:dic withTime:trackDate];
        if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppEnd]) {
            [instance autotrack:TD_APP_END_EVENT properties:nil withTime:trackDate];
        }
    }
    
    dispatch_sync([ThinkingAnalyticsSDK td_trackQueue], ^{});
    NSSetUncaughtExceptionHandler(NULL);
    for (int i = 0; i < sizeof(TDSignals) / sizeof(int); i++) {
        signal(TDSignals[i], SIG_DFL);
    }
}

// 解析crash信息
- (NSMutableDictionary *)td_getCrashInfo:(NSException *)exception {
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    NSString *crashStr;
    @try {
        if ([exception callStackSymbols]) {
            crashStr = [NSString stringWithFormat:@"Exception Reason:%@\nException Stack:%@", [exception reason], [exception callStackSymbols]];
        } else {
            NSString *exceptionStack = [[NSThread callStackSymbols] componentsJoinedByString:@"\n"];
            crashStr = [NSString stringWithFormat:@"%@ %@", [exception reason], exceptionStack];
        }
        crashStr = [crashStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];

        NSUInteger strLength = [((NSString *)crashStr) lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        NSUInteger strMaxLength = TA_PROPERTY_CRASH_LENGTH_LIMIT;
        if (strLength > strMaxLength) {
            crashStr = [NSMutableString stringWithString:[self limitString:crashStr withLength:strMaxLength - 1]];
        }

        [properties setValue:crashStr forKey:TD_CRASH_REASON];
    } @catch(NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
    return properties;
}


//- (void)td_handleUncaughtException:(NSException *)exception {
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
//    NSMutableString *crashStr = [NSMutableString string];
//    @try {
//        if ([exception callStackSymbols]) {
//            [crashStr appendFormat:@"Exception Reason:%@", [exception reason]];
//            [crashStr appendString:@"\n"];
//            [crashStr appendFormat:@"Exception Stack:%@", [exception callStackSymbols]];
//        } else {
//            NSString *exceptionStack = [[NSThread callStackSymbols] componentsJoinedByString:@"\n"];
//            if ([exception reason] && [[exception reason] isKindOfClass:[NSString class]] && [exception reason].length) {
//                [crashStr appendString:[exception reason]];
//            }
//            [crashStr appendFormat:@" %@", exceptionStack];
//        }
//        NSString *crashInfo = [crashStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
//
//        NSUInteger strLength = [((NSString *)crashInfo) lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//        NSUInteger strMaxLength = TA_PROPERTY_CRASH_LENGTH_LIMIT;
//        if (strLength > strMaxLength) {
//            crashInfo = [NSMutableString stringWithString:[self limitString:crashInfo withLength:strMaxLength - 1]];
//        }
//        [dic setValue:crashInfo forKey:TD_CRASH_REASON];
//        NSDate *trackDate = [NSDate date];
//
//        // 多实例 触发end事件和Crash事件
//        for (ThinkingAnalyticsSDK *instance in self.thinkingAnalyticsSDKInstances) {
//            [instance autotrack:TD_APP_CRASH_EVENT properties:dic withTime:trackDate];
//            if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppEnd]) {
//                [instance autotrack:TD_APP_END_EVENT properties:nil withTime:trackDate];
//            }
//        }
//    } @catch(NSException *exception) {
//        TDLogError(@"Exception Error: %@", exception);
//    }
//
//    dispatch_sync([ThinkingAnalyticsSDK td_trackQueue], ^{});
//    NSSetUncaughtExceptionHandler(NULL);
//    for (int i = 0; i < sizeof(TDSignals) / sizeof(int); i++) {
//        signal(TDSignals[i], SIG_DFL);
//    }
//}




- (NSString *)limitString:(NSString *)originalString withLength:(NSInteger)length {
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData *originalData = [originalString dataUsingEncoding:encoding];
    NSData *subData = [originalData subdataWithRange:NSMakeRange(0, length)];
    NSString *limitString = [[NSString alloc] initWithData:subData encoding:encoding];

    NSInteger index = 1;
    while (index <= 3 && !limitString) {
        if (length > index) {
            subData = [originalData subdataWithRange:NSMakeRange(0, length - index)];
            limitString = [[NSString alloc] initWithData:subData encoding:encoding];
        }
        index ++;
    }

    if (!limitString) {
        return originalString;
    }
    return limitString;
}

- (void)addThinkingInstance:(ThinkingAnalyticsSDK *)instance {
    NSParameterAssert(instance != nil);
    if (![self.thinkingAnalyticsSDKInstances containsObject:instance]) {
        [self.thinkingAnalyticsSDKInstances addObject:instance];
    }
}

@end
