//
//  Tunnel.h
//  NAT
//
//  Created by simpzan on 10/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface Tunnel : NSObject

typedef void (^Callback)(Tunnel *tunnel, NSError *error);
- (instancetype)initWithSocket:(GCDAsyncSocket *)socket :(Callback)closeCallback;

@end

