//
//  TDOSLog.m
//  Pods-DevelopProgram
//
//  Created by 杨雄 on 2024/1/22.
//

#import "TDOSLog.h"
#import "TDLogChannelConsole.h"
#import "TDLogMessage.h"

#ifndef DDLOG_MAX_QUEUE_SIZE
    #define DDLOG_MAX_QUEUE_SIZE 1000
#endif

static dispatch_queue_t g_loggingQueue;
static dispatch_semaphore_t g_queueSemaphore;
static void *const GlobalLoggingQueueIdentityKey = (void *)&GlobalLoggingQueueIdentityKey;

@interface TDOSLog ()
@property (atomic, strong) NSMutableArray<id<TDLogChannleProtocol>> *logConsumers;
@property (nonatomic, strong) dispatch_queue_t consoleLogQueue;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL enableLogFromFile;

@end

@implementation TDOSLog

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)initialize {
    static dispatch_once_t TDLogOnceToken;
    dispatch_once(&TDLogOnceToken, ^{
        g_loggingQueue = dispatch_queue_create("cn.thinking.log", NULL);

        void *nonNullValue = GlobalLoggingQueueIdentityKey;
        dispatch_queue_set_specific(g_loggingQueue, GlobalLoggingQueueIdentityKey, nonNullValue, NULL);
        g_queueSemaphore = dispatch_semaphore_create(DDLOG_MAX_QUEUE_SIZE);
    });
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.logConsumers = [NSMutableArray array];
        [self.logConsumers addObject:[[TDLogChannelConsole alloc] init]];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        const char *loggerQueueName = [@"cn.thinkingdata.analytics.osLogger" UTF8String];
        dispatch_queue_t loggerQueue = dispatch_queue_create(loggerQueueName, NULL);
        self.consoleLogQueue = loggerQueue;
        
        [self readLogFlagFromFile];
    }
    return self;
}

- (void)readLogFlagFromFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    path = [path stringByAppendingPathComponent:@"ta_log_enable.txt"];
    self.enableLogFromFile = [fileManager fileExistsAtPath:path];
}

// MARK: - Public method

+ (void)addLogConsumer:(id<TDLogChannleProtocol>)consumer {
    dispatch_async(g_loggingQueue, ^{
        if ([consumer conformsToProtocol:@protocol(TDLogChannleProtocol)]) {
            [[TDOSLog sharedInstance].logConsumers addObject:consumer];
        }
    });
}

+ (void)logMessage:(NSString *)message prefix:(NSString *)prefix type:(TDLogType)type asynchronous:(BOOL)asynchronous {
    if ([self sharedInstance].enableLogFromFile) {
        type = TDLogTypeDebug;
    }
    if (type == TDLogTypeOff) {
        return;
    }
    TDLogMessage *logMessage = [[TDLogMessage alloc] initWithMessage:message prefix:prefix type:type];
    [[self sharedInstance] queueLogMessage:logMessage asynchronously:asynchronous];
}

//MARK: - Private method

- (void)queueLogMessage:(TDLogMessage *)logMessage asynchronously:(BOOL)asyncFlag {
    dispatch_block_t logBlock = ^{
        dispatch_semaphore_wait(g_queueSemaphore, DISPATCH_TIME_FOREVER);
        @autoreleasepool {
            [self lt_log:logMessage];
        }
        dispatch_semaphore_signal(g_queueSemaphore);
    };

    if (asyncFlag) {
        dispatch_async(g_loggingQueue, logBlock);
    } else if (dispatch_get_specific(GlobalLoggingQueueIdentityKey)) {
        logBlock();
    } else {
        dispatch_sync(g_loggingQueue, logBlock);
    }
}

- (void)lt_log:(TDLogMessage *)logMessage {
    NSAssert(dispatch_get_specific(GlobalLoggingQueueIdentityKey),
             @"This method should only be run on the logging thread/queue");
    
    NSMutableString *logText = [[NSMutableString alloc] init];
    NSString *timeString = [self.dateFormatter stringFromDate:[NSDate date]];
    [logText appendFormat:@"[%@]", timeString];
    if (logMessage.prefix) {
        [logText appendFormat:@"[%@]", logMessage.prefix];
    }
    [logText appendFormat:@" %@", logMessage.message];
    
    for (id<TDLogChannleProtocol> consumer in self.logConsumers) {
        [consumer printMessage:logText type:logMessage.type];
    }
}

@end
