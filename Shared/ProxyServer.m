//
//  ProxyServer.m
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "ProxyServer.h"
#import "GCDAsyncSocket.h"
#import "Tunnel.h"

@interface ProxyServer() <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *_socket;
    NSMutableArray *_tunnels;
}
@end

@implementation ProxyServer

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"%s", __FUNCTION__);
    Tunnel *tunnel = [[Tunnel alloc]initWithSocket:newSocket];
    [_tunnels addObject:tunnel];
//    NSString *reply = @"HTTP/1.1 200 OK\r\nServer: bfe/181\r\nDate: Sat, 10 Mar 2018 06:33:17 GMT\r\nContent-Type: text/html\r\nContent-Length: 280\r\nLast-Modified: Mon, 13 Jun 2016 02:50:50 GMT\r\nConnection: Keep-Alive\r\nETag: \"575e1f8a-115\"\r\nCache-Control: private, no-cache, no-store, proxy-revalidate, no-transform\r\nPragma: no-cache\r\nAccept-Ranges: bytes\r\n\r\n123";
//    [newSocket writeData:[reply dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:3];
}

- (BOOL)startWithAddress:(NSString *)address port:(uint16_t)port {
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue() socketQueue:nil];
    NSError *err = nil;
    [_socket acceptOnInterface:address port:port error:&err];
    if (err) {
        NSLog(@"accept failed on %@:%u, %@", address, port, err);
        return NO;
    }
    NSLog(@"listenning on %@:%u", address, port);
    _tunnels = [NSMutableArray array];
    return YES;
}

- (BOOL)stop {
    [_socket setDelegate:nil delegateQueue:nil];
    [_socket disconnect];
    _socket = nil;
    return YES;
}

@end
