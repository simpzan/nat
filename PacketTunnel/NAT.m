//
//  NAT.m
//  PacketTunnel
//
//  Created by simpzan on 11/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "NAT.h"
#import "TCPPacket.h"
#import "DNSMessage.h"

NAT *instance() {
    static NAT *nat = NULL;
    if (nat == NULL) {
        nat = [[NAT alloc]init];
    }
    return nat;
}

@implementation NAT

- (instancetype)init {
    if (self = [super init]) {
        _map = [NSMutableDictionary dictionary];
        _PortMap = [NSMutableDictionary dictionary];
    }
    return self;
}


+ (NSData *)translatedPacket:(NSData *)data {
    NAT *nat = instance();
    return [nat translatedPacket:data];
}

- (NSString *)getOriginalHost:(uint16_t)sourcePort {
    NSNumber *destinationPort = @(sourcePort);
    NSString *address = _map[destinationPort];
    return address;
}
- (uint16_t)getOriginalPort:(uint16_t)sourcePort {
    NSNumber *destinationPort = @(sourcePort);
    uint16_t port = [_PortMap[destinationPort] unsignedShortValue];
    return port;
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
    if (packet.protocol == 17 && packet.destinationPort == 53) {
        DNSMessage *dns = [[DNSMessage alloc] initWithData:packet.udpData];
        NSLog(@"dns, %@", dns);
        return nil;
    }
    if (packet.protocol == 17) {
        NSString *str = [[NSString alloc]initWithData:packet.udpData encoding:NSUTF8StringEncoding];
        NSLog(@"udp data %@", str);
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

NSData *translatedPacket(NSData *data) {
    return [instance() translatedPacket:data];
}
NSString *getOriginalHost(uint16_t sourcePort) {
    return [instance() getOriginalHost:sourcePort];
}
uint16_t getOriginalPort(uint16_t sourcePort) {
    return [instance() getOriginalPort:sourcePort];
}

