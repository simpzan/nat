//
//  TCPPacket.h
//  PacketTunnel
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCPPacket : NSObject

- (instancetype)initWithData:(NSData *)data;

@property (nonatomic, copy) NSString *sourceAddress;
@property (nonatomic) uint16_t sourcePort;

@property (nonatomic, copy) NSString *destinationAddress;
@property (nonatomic) uint16_t destinationPort;

@property (nonatomic) uint8_t protocol;

- (NSData *)raw;
- (NSData *)udpData;

@end
