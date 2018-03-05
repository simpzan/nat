//
//  TunnelServer.h
//  PacketTunnel
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

typedef void (^Callback)(NSError *error);

@interface TunnelServer : NSObject

- (void)start:(NEPacketTunnelProvider *)provider :(Callback)callback;

@end
