//
//  ProxyServer.h
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProxyServer : NSObject

- (BOOL)startWithAddress:(NSString *)address port:(uint16_t)port;
- (BOOL)stop;

@end
