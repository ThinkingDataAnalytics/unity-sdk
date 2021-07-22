//
//  TDNTPServer.h
//  NTPKit
//
//  Created by Nico Cvitak on 2016-05-01.
//  Copyright © 2016 Nicholas Cvitak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDNTPServer : NSObject

NS_ASSUME_NONNULL_BEGIN

//! The server's hostname.
@property (readonly, strong, nonatomic) NSString *hostname;
//! The server's port.
@property (readonly, assign, nonatomic) NSUInteger port;
//! The NTP request timeout.
@property (assign, atomic) NSTimeInterval timeout;
//! The server's connection status.
@property (readonly, atomic, getter=isConnected) BOOL connected;

//! The default NTP server.
@property (class, readonly, nonatomic) TDNTPServer *defaultServer;

//! Initializes an NTP server with it's hostname and port.
- (instancetype)initWithHostname:(NSString *)hostname port:(NSUInteger)port NS_DESIGNATED_INITIALIZER;
//! Initializes an NTP server with it's hostname and the default NTP port.
- (instancetype)initWithHostname:(NSString *)hostname;
//! Initializes an NTP server with the default hostname and port.
- (instancetype)init;

//! Attempts to connect to the NTP server.
- (BOOL)connectWithError:(NSError *__autoreleasing _Nullable *_Nullable)error NS_REQUIRES_SUPER;
//! Disconnects from the NTP server.
- (void)disconnect NS_REQUIRES_SUPER;

//! Attempts to perform an NTP sync request.
- (BOOL)syncWithError:(NSError *__autoreleasing _Nullable *_Nullable)error NS_REQUIRES_SUPER;

//! Returns the NTP date based on the last sync request.
- (NSTimeInterval)dateWithError:(NSError *__autoreleasing _Nullable *_Nullable)error;

NS_ASSUME_NONNULL_END

@end
