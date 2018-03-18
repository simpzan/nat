//
//  PacketTunnelProvider.m
//  PacketTunnel
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "TunnelServer.h"
#import "Utils.h"
#import "Config.h"

@interface PacketTunnelProvider() {
    TunnelServer *_server;
}
@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler {
	// Add code here to start the process of connecting the tunnel.
    NSLog(@"%s", __FUNCTION__);
    _server = [[TunnelServer alloc]init];
    [_server start:self :completionHandler];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler {
	// Add code here to start the process of stopping the tunnel.
    NSLog(@"%s", __FUNCTION__);
    completionHandler();
    [_server stop];
    _server = nil;
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
	// Add code here to handle the message.
    NSString *message = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    NSLog(@"received message %@", message);
    if ([message isEqualToString:@"extension.createTCPConnectionThroughTunnelToEndpoint"]) {
        [_server testTcpConnectionThroughTunnel];
    } else {
        test(routedIp);
    }
    completionHandler(nil);
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler {
	// Add code here to get ready to sleep.
	completionHandler();
}

- (void)wake {
	// Add code here to wake up.
}

@end
