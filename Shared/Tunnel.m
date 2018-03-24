//
//  Tunnel.m
//  NAT
//
//  Created by simpzan on 10/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "Tunnel.h"
#import "NAT.h"

@interface Tunnel() <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *_inSocket;
    GCDAsyncSocket *_outSocket;
    Callback _closeCallback;
    NSString *_inDescription;
    NSString *_outDescription;
}
@end

@implementation Tunnel

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket :(Callback)closeCallback {
    if (self = [super init]) {
        _inSocket = socket;
        _closeCallback = closeCallback;
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
        [socket readDataWithTimeout:-1 tag:12];
//        NSString *host = [socket connectedHost];
//        UInt16 port = [socket connectedPort];
//        NSLog(@"%s %@ %u", __FUNCTION__, host, port);
//        NSString *reply = @"HTTP/1.1 200 OK\r\nServer: bfe/181\r\nDate: Sat, 10 Mar 2018 06:33:17 GMT\r\nContent-Type: text/html\r\nContent-Length: 280\r\nLast-Modified: Mon, 13 Jun 2016 02:50:50 GMT\r\nConnection: Keep-Alive\r\nETag: \"575e1f8a-115\"\r\nCache-Control: private, no-cache, no-store, proxy-revalidate, no-transform\r\nPragma: no-cache\r\nAccept-Ranges: bytes\r\n\r\n123";
//        [_inSocket writeData:[reply dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:3];
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str %ld %d %@", tag, (int)data.length, str);
    if (sock == _inSocket) {
        NSLog(@"data from client");
        _outSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        uint16_t port = [_inSocket connectedPort];
        NSString *host = getOriginalHost(port);
        uint16_t thePort = getOriginalPort(port);
        if (!host) {
            host = @"140.205.16.92";
            thePort = 80;
        }
        NSLog(@"port %d, %@:%d", (int)port, host, (int)thePort);
        _outDescription = [NSString stringWithFormat:@"%@:%u", host, thePort];
        _inDescription = [NSString stringWithFormat:@"%@:%u", _inSocket.connectedHost, _inSocket.connectedPort];
        NSError *error;
        BOOL result = [_outSocket connectToHost:host onPort:thePort error:&error];
        if (!result) {
            NSLog(@"failed to connect to ,%@", error);
            return;
        }
        [_outSocket writeData:data withTimeout:-1 tag:4];
        [_outSocket readDataWithTimeout:-1 tag:8];
        [_inSocket readDataWithTimeout:-1 tag:9];
    } else {
        NSLog(@"data from server");
        [_inSocket writeData:data withTimeout:-1 tag:5];
        [_inSocket readDataWithTimeout:-1 tag:9];
        [_outSocket readDataWithTimeout:-1 tag:8];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSString *name = sock == _inSocket ? @"in" : @"out";
    NSLog(@"%s %@ %u", __FUNCTION__, name, (int)tag);
//    if (sock == _inSocket) {
//        [_inSocket disconnect];
//    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSString *name = sock == _inSocket ? @"in" : @"out";
    NSLog(@"closed %@, %@", name, err);
    GCDAsyncSocket *theOtherSock = sock == _inSocket ? _outSocket : _inSocket;
    if (theOtherSock.isDisconnected) _closeCallback(self, NULL);
    else [theOtherSock disconnectAfterWriting];
}

- (NSString *)description {
    return [[NSString alloc]initWithFormat:@"Tunnel(%@ -> %@)", _inDescription, _outDescription];
}

@end

