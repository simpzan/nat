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


static NSString *interfaceIp = @"10.25.1.1";
static NSString *remoteIp = @"10.25.1.2";
static NSString *fakeIp = @"10.25.1.100";
static uint16_t proxyPort = 12345;
static NSString *proxyIp = @"10.25.1.1";
static NSString *dnsIp = @"114.114.114.114";
static NSString *netMask = @"255.255.255.0";

@interface TunnelServer() {
    NSMutableDictionary *_map;
    NSMutableDictionary *_PortMap;
}
@end

@implementation TunnelServer

- (NEPacketTunnelNetworkSettings *)getTunnelSettings {
    NEIPv4Route *route = [[NEIPv4Route alloc]initWithDestinationAddress:@"115.239.210.27" subnetMask:netMask];
    NEIPv4Settings *v4 = [[NEIPv4Settings alloc]initWithAddresses:@[interfaceIp] subnetMasks:@[netMask]];
    v4.includedRoutes = @[route];

    NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc]initWithTunnelRemoteAddress:remoteIp];
    settings.MTU = [NSNumber numberWithInt:1500];
    settings.IPv4Settings = v4;
    settings.DNSSettings = [[NEDNSSettings alloc]initWithServers:@[dnsIp]];
    return settings;
}

- (NSData *)translatedPacket:(NSData *)data {
    TCPPacket *packet = [[TCPPacket alloc]initWithData:data];
    NSLog(@"in %@:%u -> %@:%u", packet.sourceAddress, packet.sourcePort, packet.destinationAddress, packet.destinationPort);
    uint16_t proxyServerPort = proxyPort;
    NSString *fakeSourceIP = fakeIp;
    NSString *proxyServerIP = proxyIp;

    if (![packet.sourceAddress isEqualToString:interfaceIp]) {
        NSLog(@"Does not know how to handle packet");
        return nil;
    }
    if (packet.protocol != 6) {
        NSLog(@"unknown protocol %d", (int)packet.protocol);
        return nil;
    }

    if (packet.sourcePort == proxyServerPort) {
        // load
        NSNumber *destinationPort = @(packet.destinationPort);
        NSString *address = _map[destinationPort];
        uint16_t port = [_PortMap[destinationPort] unsignedShortValue];
        packet.sourcePort = port;
        packet.sourceAddress = address;
        packet.destinationAddress = interfaceIp;
    } else {
        // save
        NSNumber *sourcePort = @(packet.sourcePort);
        _map[sourcePort] = packet.destinationAddress;
        _PortMap[sourcePort] = @(packet.destinationPort);
        packet.sourceAddress = fakeSourceIP;
        packet.destinationAddress = proxyServerIP;
        packet.destinationPort = proxyServerPort;
    }
    NSLog(@"out %@:%u -> %@:%u", packet.sourceAddress, packet.sourcePort, packet.destinationAddress, packet.destinationPort);
    return packet.raw;
}

- (void)readPackets:(NEPacketTunnelFlow *)flow {
    [flow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        NSLog(@"read %ld", packets.count);
        [packets enumerateObjectsUsingBlock:^(NSData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *translatedPacket = [self translatedPacket:data];
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
    _map = [NSMutableDictionary dictionary];
    _PortMap = [NSMutableDictionary dictionary];

    [provider setTunnelNetworkSettings:[self getTunnelSettings] completionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"setTunnelNetworkSettings error, %@", error);
        } else {
            [self readPackets:provider.packetFlow];
        }
        return callback(error);
    }];
}

@end
