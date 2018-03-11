//
//  NAT.m
//  PacketTunnel
//
//  Created by simpzan on 11/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "NAT.h"
#import "TCPPacket.h"

@implementation NAT

- (instancetype)init {
    if (self = [super init]) {
        _map = [NSMutableDictionary dictionary];
        _PortMap = [NSMutableDictionary dictionary];
    }
    return self;
}


+ (NSData *)translatedPacket:(NSData *)data {
    static NAT *nat = NULL;
    if (nat == NULL) {
        nat = [[NAT alloc]init];
    }
    return [nat translatedPacket:data];
}

- (NSData *)translatedPacket:(NSData *)data {
    TCPPacket *packet = [[TCPPacket alloc]initWithData:data];
    NSLog(@"in %@:%u -> %@:%u", packet.sourceAddress, packet.sourcePort, packet.destinationAddress, packet.destinationPort);
    uint16_t proxyServerPort = extensionProxyPort;
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

@end
