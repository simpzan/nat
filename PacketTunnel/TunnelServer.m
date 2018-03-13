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

- (NEProxySettings *)getProxySettings {
    NEProxySettings *proxySettings = [[NEProxySettings alloc] init];
    proxySettings.HTTPEnabled = true;
    proxySettings.HTTPServer = [[NEProxyServer alloc] initWithAddress:@"127.0.0.1" port:extensionProxyPort];
    proxySettings.HTTPSEnabled = true;
    proxySettings.HTTPSServer = proxySettings.HTTPServer;
    proxySettings.excludeSimpleHostnames = true;
    // This will match all domains
    proxySettings.matchDomains = @[@""];
    return proxySettings;
}

- (NEPacketTunnelNetworkSettings *)getTunnelSettings {
    NEIPv4Route *route = [[NEIPv4Route alloc]initWithDestinationAddress:routedIp subnetMask:netMask];
    NEIPv4Route *dnsRoute = [[NEIPv4Route alloc]initWithDestinationAddress:dnsIp subnetMask:@"255.255.255.255"];
    
    NEIPv4Route *defaultRoute = [NEIPv4Route defaultRoute];
    NEIPv4Settings *v4 = [[NEIPv4Settings alloc]initWithAddresses:@[interfaceIp] subnetMasks:@[netMask]];
    v4.includedRoutes = @[route];
    v4.excludedRoutes = @[dnsRoute];

    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]initWithTunnelRemoteAddress:remoteIp];
    settings.MTU = [NSNumber numberWithInt:1500];
    settings.IPv4Settings = v4;
    settings.DNSSettings = [[NEDNSSettings alloc]initWithServers:@[dnsIp]];
    settings.proxySettings = [self getProxySettings];
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
    
    _proxy = [[ProxyServer alloc]init];
    _provider = provider;
    [provider setTunnelNetworkSettings:[self getTunnelSettings] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setTunnelNetworkSettings error, %@", error);
        } else {
            [_proxy startWithAddress:proxyIp port:extensionProxyPort];
            [self readPackets:provider.packetFlow];
        }
        return callback(error);
    }];
}

- (void)test2 {
    NSLog(@"%s", __FUNCTION__);

    NWEndpoint *endpoint = [NWHostEndpoint endpointWithHostname:@"115.239.210.27" port:@"88"];
//    [_provider createTCPConnectionThroughTunnelToEndpoint:endpoint enableTLS:NO TLSParameters:nil delegate:nil];
    NWTCPConnection *connection = [_provider createTCPConnectionToEndpoint:endpoint enableTLS:NO TLSParameters:nil delegate:nil];
}

- (void)stop {
    [_proxy stop];
}
@end
