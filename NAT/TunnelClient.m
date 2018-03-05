//
//  TunnelClient.m
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <NetworkExtension/NetworkExtension.h>
#import "TunnelClient.h"


@interface TunnelClient () {
    NETunnelProviderManager *_manager;
}
@end


@implementation TunnelClient

typedef void (^ManagerCallback)(NETunnelProviderManager *__nullable manager);

- (void)loadManager:(ManagerCallback)callback {
    NSLog(@"%s", __FUNCTION__);

    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(
                                                                           NSArray<NETunnelProviderManager *> * _Nullable managers,
                                                                           NSError * _Nullable error) {
        if (!error && [managers count] > 0) callback(managers[0]);
        else callback(nil);
    }];
}
- (void)createManager:(ManagerCallback)callback {
    NSLog(@"%s", __FUNCTION__);

    NETunnelProviderProtocol *config = [[NETunnelProviderProtocol alloc]init];
    config.providerBundleIdentifier = @"com.simpzan.NAT.PacketTunnel";
    config.serverAddress = @"10.0.0.2";

    NETunnelProviderManager *manager = [[NETunnelProviderManager alloc]init];
    manager.enabled = YES;
    manager.protocolConfiguration = config;
    [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) callback(nil);
        else callback(manager);
    }];
}
- (void)getManager:(ManagerCallback)callback {
    [self loadManager:^(NETunnelProviderManager * _Nullable manager) {
        if (manager) return callback(manager);
        [self createManager:^(NETunnelProviderManager * _Nullable manager) {
            if (!manager) return callback(nil);

            [self loadManager:callback];
        }];
    }];
}

- (void)start {
    [self getManager:^(NETunnelProviderManager * _Nullable manager) {
        if (!manager) return NSLog(@"failed to get manager");

        _manager = manager;
        NSError *error = nil;
        BOOL result = [manager.connection startVPNTunnelWithOptions:nil andReturnError:&error];
        NSLog(@"manager %p, result %d, %@", manager, result, error);

    }];
}

- (void)stop {
    [_manager.connection stopVPNTunnel];
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)connected {
    return _manager && _manager.connection.status == NEVPNStatusConnected;
}


@end
