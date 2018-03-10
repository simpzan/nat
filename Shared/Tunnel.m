//
//  Tunnel.m
//  NAT
//
//  Created by simpzan on 10/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "Tunnel.h"

@interface Tunnel() <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *_inSocket;
}
@end

@implementation Tunnel

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket {
    if (self = [super init]) {
        _inSocket = socket;
        [socket setDelegate:self delegateQueue:dispatch_get_main_queue()];
        [socket readDataWithTimeout:-1 tag:12];
        NSString *host = [socket connectedHost];
        UInt16 port = [socket connectedPort];
        NSLog(@"%s %@ %u", __FUNCTION__, host, port);
        NSString *reply = @"HTTP/1.1 200 OK\r\nServer: bfe/181\r\nDate: Sat, 10 Mar 2018 06:33:17 GMT\r\nContent-Type: text/html\r\nContent-Length: 280\r\nLast-Modified: Mon, 13 Jun 2016 02:50:50 GMT\r\nConnection: Keep-Alive\r\nETag: \"575e1f8a-115\"\r\nCache-Control: private, no-cache, no-store, proxy-revalidate, no-transform\r\nPragma: no-cache\r\nAccept-Ranges: bytes\r\n\r\n123";
        [_inSocket writeData:[reply dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:3];
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str %ld %@", tag, str);
}


@end
