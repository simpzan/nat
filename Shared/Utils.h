//
//  Utils.h
//  PacketTunnel
//
//  Created by simpzan on 07/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#include <arpa/inet.h>
#import <Foundation/Foundation.h>

NSString *getAddress(const void *data);
void setAddress(void *data, NSString *address);

uint16_t getPort(const void *data);
void setPort(void *data, uint16_t port);

void delay(double delayInSeconds, void(^callback)(void));

@interface NSArray(Map)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end


@interface NSData(Hex)
- (NSString*)hexRepresentation;
@end
