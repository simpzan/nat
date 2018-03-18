//
//  TunnelClient.h
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TunnelClient : NSObject

- (void)start;
- (void)stop;
- (BOOL)connected;

typedef void (^StateChangeCallback)(BOOL state);
- (void)monitorState:(StateChangeCallback)callback;

- (void)sendMessage:(NSString *)message;

@end
