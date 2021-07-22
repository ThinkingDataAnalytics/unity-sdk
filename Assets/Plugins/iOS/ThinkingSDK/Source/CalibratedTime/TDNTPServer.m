//
//  TDNTPServer.m
//  NTPKit
//
//  Created by Nico Cvitak on 2016-05-01.
//  Copyright © 2016 Nicholas Cvitak. All rights reserved.
//

#import "TDNTPServer.h"

#import "TDNTPTypes.h"
#import "TDLogging.h"

#import <arpa/inet.h>
#import <assert.h>
#import <netdb.h>
#import <sys/time.h>

@implementation TDNTPServer {
    NSTimeInterval _timeout;
    int _socket;
    
    NSTimeInterval _offset;
}

//! The number of seconds from 1900 to 1970
static const uint32_t kSecondsFrom1900To1970 = 2208988800UL;

//! Returns the local time as an NTP ufixed64 timestamp
static ufixed64_t ntp_localtime_get_ufixed64() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return ufixed64((uint32_t)tv.tv_sec + kSecondsFrom1900To1970, tv.tv_usec * (pow(2, 32) / USEC_PER_SEC));
}

+ (TDNTPServer *)defaultServer {
    static TDNTPServer *server = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        server = [[TDNTPServer alloc] init];
    });
    return server;
}

- (instancetype)initWithHostname:(NSString *)hostname port:(NSUInteger)port {
    self = [super init];
    if (self) {
        _hostname = [hostname copy];
        _port = port;
        _timeout = 3.0;
        _socket = -1;
        
        _offset = NAN;
    }
    return self;
}

- (instancetype)initWithHostname:(NSString *)hostname {
    return [self initWithHostname:hostname port:123];
}

- (instancetype)init {
    return [self initWithHostname:@"pool.ntp.org"];
}

- (void)dealloc {
    [self disconnect];
}

- (void)setTimeout:(NSTimeInterval)timeout {
    assert(timeout > 0 && isfinite(timeout));
    @synchronized (self) {
        _timeout = timeout;
        if (_socket >= 0) {
            struct timeval tv = { .tv_sec = _timeout, .tv_usec = (_timeout - trunc(_timeout)) * USEC_PER_SEC };
            setsockopt(_socket, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));
            setsockopt(_socket, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
        }
        
    }
}

- (NSTimeInterval)timeout {
    @synchronized (self) {
        return _timeout;
    }
}

- (BOOL)isConnected {
    @synchronized (self) {
        return _socket >= 0;
    }
}

- (BOOL)connectWithError:(NSError *__autoreleasing _Nullable *_Nullable)error {
    @synchronized (self) {
        if (_socket >= 0) {
            return YES;
        }
        
        // setup hints.
        struct addrinfo hints = {0}, *addrinfo = NULL;
        hints.ai_family = AF_UNSPEC; // getaddrinfo will resolve (AF_INET or AF_INET6)
        hints.ai_socktype = SOCK_DGRAM; // UDP
        
        // get port string.
        NSString *port = [[NSString alloc] initWithFormat:@"%lu", (unsigned long) _port];
        
        // get address info.
        int getaddrinfo_err = getaddrinfo(_hostname.UTF8String, port.UTF8String, &hints, &addrinfo);
        if (getaddrinfo_err != 0) {
            if (error) {
                NSString *errorDescription = [[NSString alloc] initWithUTF8String:gai_strerror(getaddrinfo_err)];
                NSDictionary *errorInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
                *error = [NSError errorWithDomain:@"netdb" code:getaddrinfo_err userInfo:errorInfo];
            }
            return NO;
        }
        
        // create the socket.
        const int sock = socket(addrinfo->ai_family, addrinfo->ai_socktype, addrinfo->ai_protocol);
        if (sock < 0) {
            if (error) {
                *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:errno userInfo:nil];
            }
            freeaddrinfo(addrinfo);
            return NO;
        }
        
        // set nonblocking.
        fcntl(sock, F_SETFL, fcntl(sock, F_GETFL, 0) | O_NONBLOCK);
        
        // connect async with timeout.
        struct timeval timeout = { .tv_sec = _timeout, .tv_usec = (_timeout - trunc(_timeout)) * USEC_PER_SEC };
        int connect_err = connect(sock, addrinfo->ai_addr, addrinfo->ai_addrlen) ? errno : 0;
        if (connect_err == EINPROGRESS) {
            fd_set fd;
            FD_ZERO(&fd);
            FD_SET(sock, &fd);
            
            const int select_err = select(sock + 1, &fd, &fd, NULL, &timeout);
            if (select_err <= 0) {
                connect_err = select_err ? errno : ETIMEDOUT;
            } else {
                socklen_t optlen = sizeof(connect_err);
                getsockopt(sock, SOL_SOCKET, SO_ERROR, &connect_err, &optlen);
            }
        }
        freeaddrinfo(addrinfo);
        if (connect_err) {
            if (error) {
                *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:connect_err userInfo:nil];
            }
            close(sock);
            return NO;
        }
        
        // set blocking.
        fcntl(sock, F_SETFL, fcntl(sock, F_GETFL, 0) & ~O_NONBLOCK);
        
        // set timeout.
        setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
        
        [self willChangeValueForKey:@"connected"];
        _socket = sock;
        [self didChangeValueForKey:@"connected"];
        
        return YES;
    }
}

- (void)disconnect {
    @synchronized (self) {
        if (_socket >= 0) {
            close(_socket);
            
            [self willChangeValueForKey:@"connected"];
            _socket = -1;
            [self didChangeValueForKey:@"connected"];
        }
    }
}

- (BOOL)syncWithError:(NSError *__autoreleasing _Nullable *_Nullable)error {
    @synchronized (self) {
        if (![self connectWithError:error]) {
            return NO;
        }
        
        // setup NTP packet.
        ntp_packet_t packet = {0};
        packet.version_number = 4; // NTPv4.
        packet.mode = 3; // client mode.
        packet.transmit_timestamp = ntp_localtime_get_ufixed64(); // client transmit time.
        
        // convert to network byte order.
        packet = hton_ntp_packet(packet);
        
        // send packet to server.
        const ssize_t send_s = send(_socket, &packet, sizeof(packet), 0);
        const int send_err = send_s == sizeof(packet) ? 0 : send_s >= 0 ? EIO : errno;
        if (send_err) {
            if (error) {
                *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:send_err userInfo:nil];
            }
            return NO;
        }
        
        // receive packet from server.
        const ssize_t recv_s = recv(_socket, &packet, sizeof(packet), 0);
        const int recv_err = recv_s == sizeof(packet) ? 0 : recv_s >= 0 ? EIO : errno;
        if (recv_err) {
            if (error) {
                *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:recv_err userInfo:nil];
            }
            return NO;
        }
        
        // convert to host byte order.
        packet = ntoh_ntp_packet(packet);
        
        // calculate and update host delay.
        const double T[4] = {
            ufixed64_as_double(packet.originate_timestamp), // client transmit time.
            ufixed64_as_double(packet.receive_timestamp), // server receive time.
            ufixed64_as_double(packet.transmit_timestamp), // server transmit time.
            ufixed64_as_double(ntp_localtime_get_ufixed64()), // client receive time.
        };
        _offset = ((T[1] - T[0]) + (T[2] - T[3])) / 2.0;
        
        TDLogDebug(@"%s %f", __func__, _offset);
        return YES;
    }
}

- (NSTimeInterval)dateWithError:(NSError *__autoreleasing _Nullable *_Nullable)error {
    @synchronized (self) {
        return isfinite(_offset) || [self syncWithError:error] ? _offset : 0;
    }
}

@end
