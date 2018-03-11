//
//  TunnelServer.m
//  PacketTunnel
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "TunnelServer.h"
#import "TCPPacket.h"
#import "Utils.h"
#import "ProxyServer.h"
#import "Config.h"
#import "NAT.h"


@interface TunnelServer() {
    ProxyServer *_proxy;
    NEPacketTunnelProvider *_provider;
}
@end

@implementation TunnelServer

- (NEPacketTunnelNetworkSettings *)getTunnelSettings {
    NEIPv4Route *route = [[NEIPv4Route alloc]initWithDestinationAddress:routedIp subnetMask:netMask];
    NEIPv4Settings *v4 = [[NEIPv4Settings alloc]initWithAddresses:@[interfaceIp] subnetMasks:@[netMask]];
    v4.includedRoutes = @[route];

    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]initWithTunnelRemoteAddress:remoteIp];
    settings.MTU = [NSNumber numberWithInt:1500];
    settings.IPv4Settings = v4;
    settings.DNSSettings = [[NEDNSSettings alloc]initWithServers:@[dnsIp]];
    return settings;
}



- (void)readPackets:(NEPacketTunnelFlow *)flow {
    [flow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        [packets enumerateObjectsUsingBlock:^(NSData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *translatedPacket = [NAT translatedPacket:data];
//            NSLog(@"translated: \n%@ \n%@", [data hexRepresentation], [translatedPacket hexRepresentation]);
            if (!translatedPacket) return;
            
            BOOL result = [flow writePackets:@[translatedPacket] withProtocols:@[protocols[idx]]];
            if (!result) NSLog(@"writePackets failed");
        }];

        [self readPackets:flow];
    }];
}
- (void)start:(NEPacketTunnelProvider *)provider :(Callback)callback {
    NSLog(@"%s", __FUNCTION__);
//    [self test];
    
    _proxy = [[ProxyServer alloc]init];
    _provider = provider;
    [provider setTunnelNetworkSettings:[self getTunnelSettings] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setTunnelNetworkSettings error, %@", error);
        } else {
            [_proxy startWithAddress:proxyIp port:extensionProxyPort];
            [self readPackets:provider.packetFlow];
        }
        
        delay(1, ^{
            [self test2];
        });
        return callback(error);
    }];
}

- (void)test {
    NSError *err = nil;
    NSString *response =  [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://115.239.210.27"] encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"response %@, %@", response, err);
}

- (void)test2 {
    NSLog(@"%s", __FUNCTION__);

    NWEndpoint *endpoint = [NWHostEndpoint endpointWithHostname:@"115.239.210.27" port:@"88"];
    [_provider createTCPConnectionThroughTunnelToEndpoint:endpoint enableTLS:NO TLSParameters:nil delegate:nil];
//    NWTCPConnection *connection = [_provider createTCPConnectionToEndpoint:endpoint enableTLS:NO TLSParameters:nil delegate:nil];
    
    
}

- (void)stop {
    [_proxy stop];
}
@end
