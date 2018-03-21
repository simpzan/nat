//
//  NAT.h
//  PacketTunnel
//
//  Created by simpzan on 11/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"

@interface NAT : NSObject {
    NSMutableDictionary *_map;
    NSMutableDictionary *_PortMap;
}

+ (NSData *)translatedPacket:(NSData *)data;

@end

NSData *translatedPacket(NSData *data);
NSString *getOriginalHost(uint16_t sourcePort);
uint16_t getOriginalPort(uint16_t sourcePort);
