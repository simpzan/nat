//
//  Tunnel.h
//  NAT
//
//  Created by simpzan on 10/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface Tunnel : NSObject

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket;

@end
