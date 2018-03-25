//
//  DNSMessage.h
//  NAT
//
//  Created by simpzan on 25/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSMessage : NSObject {
    NSString *_queryName;
}

- (instancetype)initWithData:(NSData *)data;
- (NSString *)queryName;

@end
