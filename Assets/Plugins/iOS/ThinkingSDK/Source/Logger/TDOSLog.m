#import "TDOSLog.h"

#import <os/log.h>

#ifndef DDLOG_MAX_QUEUE_SIZE
    #define DDLOG_MAX_QUEUE_SIZE 1000 
#endif

static void *const GlobalLoggingQueueIdentityKey = (void *)&GlobalLoggingQueueIdentityKey;

@interface TDOSLog ()
{
    id <TDLogger> _logger;
    dispatch_queue_t _loggerQueue;
}

@end

@implementation TDOSLog

static dispatch_queue_t _loggingQueue;
static dispatch_group_t _loggingGroup;
static dispatch_semaphore_t _queueSemaphore;

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance addLogger:[TDAbstractLogger sharedInstance]];
    });

    return sharedInstance;
}

+ (void)initialize {
    static dispatch_once_t TDLogOnceToken;

    dispatch_once(&TDLogOnceToken, ^{
        _loggingQueue = dispatch_queue_create("cn.thinking.log", NULL);
        _loggingGroup = dispatch_group_create();

        void *nonNullValue = GlobalLoggingQueueIdentityKey;
        dispatch_queue_set_specific(_loggingQueue, GlobalLoggingQueueIdentityKey, nonNullValue, NULL);

        _queueSemaphore = dispatch_semaphore_create(DDLOG_MAX_QUEUE_SIZE);
    });
}

+ (void)addLogger {
    [self.sharedInstance addLogger:[TDAbstractLogger sharedInstance]];
}

- (void)addLogger:(id <TDLogger>)logger {
    dispatch_async(_loggingQueue, ^{ @autoreleasepool {
        [self lt_addLogger:logger];
    } });
}

- (void)queueLogMessage:(TDLogMessage *)logMessage asynchronously:(BOOL)asyncFlag {
    dispatch_block_t logBlock = ^{
        dispatch_semaphore_wait(_queueSemaphore, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            [self lt_log:logMessage];
        }
    };

    if (asyncFlag) {
        dispatch_async(_loggingQueue, logBlock);
    } else if (dispatch_get_specific(GlobalLoggingQueueIdentityKey)) {
        logBlock();
    } else {
        dispatch_sync(_loggingQueue, logBlock);
    }
}

+ (void)log:(BOOL)asynchronous
    message:(NSString *)message
       type:(TDLoggingLevel)type {
    [self.sharedInstance log:asynchronous message:message type:type];
}

- (void)log:(BOOL)asynchronous
    message:(NSString *)message
       type:(TDLoggingLevel)type {
    TDLogMessage *logMessage = [[TDLogMessage alloc] initWithMessage:message type:type];
    [self queueLogMessage:logMessage asynchronously:asynchronous];
}

- (void)lt_addLogger:(id <TDLogger>)logger {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");
    const char *loggerQueueName = [@"cn.thinkingdata.analytics.osLogger" UTF8String];
    dispatch_queue_t loggerQueue = dispatch_queue_create(loggerQueueName, NULL);
    _logger = logger;
    _loggerQueue = loggerQueue;
}

- (void)lt_log:(TDLogMessage *)logMessage {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");

    dispatch_group_async(_loggingGroup, _loggerQueue, ^{ @autoreleasepool {
        [self->_logger logMessage:logMessage];
    } });

    dispatch_group_wait(_loggingGroup, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(_queueSemaphore);
}

@end

@interface TDLogMessage ()
{
@public
    NSString *_message;
    TDLoggingLevel _type;
}

@end

@implementation TDLogMessage

- (instancetype)initWithMessage:(NSString *)message
                           type:(TDLoggingLevel)type {
    if ((self = [super init])) {
        _message      = [message copy];
        _type         = type;
    }
    return self;
}

@end

@interface TDAbstractLogger ()

@property (strong, nonatomic, readwrite) os_log_t logger;
@property (class, readonly, strong) TDAbstractLogger *sharedInstance;

@end

@implementation TDAbstractLogger

static TDAbstractLogger *sharedInstance;

+ (instancetype)sharedInstance {
    static dispatch_once_t TDOSLoggerOnceToken;
    
    dispatch_once(&TDOSLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (os_log_t)getLogger {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    return os_log_create("cn.thinkingdata.analytics.log", "THINKING");
#pragma clang diagnostic pop
}

- (os_log_t)logger {
    if (_logger == nil)  {
        _logger = [self getLogger];
    }
    return _logger;
}

- (void)logMessage:(TDLogMessage *)logMessage {
#ifdef __IPHONE_10_0
    if (@available(iOS 10.0, *)) {
        NSString *message = logMessage->_message;
        if (message != nil) {
            const char *msg = [message UTF8String];
            __auto_type logger = [self logger];
            switch (logMessage->_type) {
                case TDLoggingLevelDebug:
                    os_log_debug(logger, "%{public}s", msg);
                    break;
                case TDLoggingLevelInfo:
                    os_log_info(logger, "%{public}s", msg);
                    break;
                case TDLoggingLevelError:
                    os_log_error(logger, "%{public}s", msg);
                    break;
                case TDLoggingLevelNone:
                default:
                    break;
            }
        }
    }
#endif
}

@end

