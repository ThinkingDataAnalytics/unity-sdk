
#import <Foundation/Foundation.h>

@interface TDNTPServer : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (readonly, strong, nonatomic) NSString *hostname;

@property (readonly, assign, nonatomic) NSUInteger port;

@property (assign, atomic) NSTimeInterval timeout;

@property (readonly, atomic, getter=isConnected) BOOL connected;

@property (class, readonly, nonatomic) TDNTPServer *defaultServer;

- (instancetype)initWithHostname:(NSString *)hostname port:(NSUInteger)port NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHostname:(NSString *)hostname;
- (instancetype)init;
- (BOOL)connectWithError:(NSError *__autoreleasing _Nullable *_Nullable)error NS_REQUIRES_SUPER;
- (void)disconnect NS_REQUIRES_SUPER;
- (BOOL)syncWithError:(NSError *__autoreleasing _Nullable *_Nullable)error NS_REQUIRES_SUPER;
- (NSTimeInterval)dateWithError:(NSError *__autoreleasing _Nullable *_Nullable)error;

NS_ASSUME_NONNULL_END

@end
