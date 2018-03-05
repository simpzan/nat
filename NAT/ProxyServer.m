//
//  ProxyServer.m
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "ProxyServer.h"
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface ProxyServer() <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *_socket;
}
@end

@implementation ProxyServer

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)startWithAddress:(NSString *)address port:(uint16)port {
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue() socketQueue:nil];
    NSError *err = nil;
    [_socket acceptOnInterface:address port:port error:&err];
    if (err) {
        NSLog(@"accept failed on %@:%u, %@", address, port, err);
        return NO;
    }
    NSLog(@"listenning on %@:%u", address, port);
    return YES;
}

- (BOOL)stop {
    [_socket setDelegate:nil delegateQueue:nil];
    [_socket disconnect];
    _socket = nil;
    return YES;
}

@end
