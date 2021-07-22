#import "ThinkingExceptionHandler.h"

#include <libkern/OSAtomic.h>
#include <stdatomic.h>
#import "TDLogging.h"

static NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
static NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";

static volatile atomic_int_fast32_t UncaughtExceptionCount = 0;
static const atomic_int_fast32_t UncaughtExceptionMaximum = 10;

@interface ThinkingExceptionHandler ()

@property (nonatomic) NSUncaughtExceptionHandler *defaultExceptionHandler;
@property (nonatomic, strong) NSHashTable *thinkingAnalyticsSDKInstances;
@property (nonatomic, unsafe_unretained) struct sigaction *prev_signal_handlers;

@end

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
        _prev_signal_handlers = calloc(NSIG, sizeof(struct sigaction));
        
        [self setupHandlers];
    }
    return self;
}

static int signals[] = {SIGILL, SIGABRT, SIGBUS, SIGSEGV, SIGFPE, SIGPIPE, SIGTRAP};
- (void)setupHandlers {
    _defaultExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&TDHandleException);
    
    struct sigaction action;
    sigemptyset(&action.sa_mask);
    action.sa_flags = SA_SIGINFO;
    action.sa_sigaction = &TDSignalHandler;
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        struct sigaction prev_action;
        int err = sigaction(signals[i], &action, &prev_action);
        if (err == 0) {
            memcpy(_prev_signal_handlers + signals[i], &prev_action, sizeof(prev_action));
        } else {
            TDLogError(@"Errored while trying to set up sigaction for signal %d", signals[i]);
        }
    }
}

static void TDHandleException(NSException *exception) {
    ThinkingExceptionHandler *handler = [ThinkingExceptionHandler sharedHandler];
    
    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&UncaughtExceptionCount, 1, memory_order_relaxed);
    if (exceptionCount <= UncaughtExceptionMaximum) {
        [handler td_handleUncaughtException:exception];
    }
    
    if (handler.defaultExceptionHandler) {
        handler.defaultExceptionHandler(exception);
    }
}

- (void)dealloc {
    free(_prev_signal_handlers);
}

static void TDSignalHandler(int signalNumber, struct __siginfo *info, void *context) {
    ThinkingExceptionHandler *handler = [ThinkingExceptionHandler sharedHandler];
    
    atomic_int_fast32_t exceptionCount = atomic_fetch_add_explicit(&UncaughtExceptionCount, 1, memory_order_relaxed);
    if (exceptionCount <= UncaughtExceptionMaximum) {
        NSDictionary *userInfo = @{UncaughtExceptionHandlerSignalKey: @(signalNumber)};
        NSException *exception = [NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
                                                         reason:[NSString stringWithFormat:@"Signal %d was raised.", signalNumber]
                                                       userInfo:userInfo];
        [handler td_handleUncaughtException:exception];
    }
    
    struct sigaction prev_action = handler.prev_signal_handlers[signalNumber];
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

        NSDate *trackDate = [NSDate date];
        for (ThinkingAnalyticsSDK *instance in self.thinkingAnalyticsSDKInstances) {
            [instance autotrack:TD_APP_CRASH_EVENT properties:properties withTime:trackDate];
            if (![instance isAutoTrackEventTypeIgnored:ThinkingAnalyticsEventTypeAppEnd]) {
                [instance autotrack:TD_APP_END_EVENT properties:nil withTime:trackDate];
            }
        }
    } @catch(NSException *exception) {
        TDLogError(@"%@ error: %@", self, exception);
    }
    
    dispatch_sync([ThinkingAnalyticsSDK serialQueue], ^{});
    
    NSSetUncaughtExceptionHandler(NULL);
    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
        signal(signals[i], SIG_DFL);
    }
    TDLogInfo(@"Encountered an uncaught exception.");
}

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
