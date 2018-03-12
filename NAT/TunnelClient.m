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
    id _observer;
}
@end

extern NSString *providerBundleIdentifier;

@implementation TunnelClient

typedef void (^ManagerCallback)(NETunnelProviderManager *__nullable manager);

- (void)loadManager:(ManagerCallback)callback {
    NSLog(@"%s", __FUNCTION__);

    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(
                                                                           NSArray<NETunnelProviderManager *> * _Nullable managers,
                                                                           NSError * _Nullable error) {
        if (error) return callback(nil);
        
        __block NETunnelProviderManager *result = nil;
        [managers enumerateObjectsUsingBlock:^(NETunnelProviderManager * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj protocolConfiguration] isKindOfClass:[NETunnelProviderProtocol class]]) {
                NETunnelProviderProtocol *config = (NETunnelProviderProtocol *)[obj protocolConfiguration];
                if ([config.providerBundleIdentifier isEqualToString:providerBundleIdentifier]) {
                    result = obj;
                    *stop = YES;
                }
            }
        }];
        callback(result);
    }];
}
- (void)createManager:(ManagerCallback)callback {
    NSLog(@"%s", __FUNCTION__);

    NETunnelProviderProtocol *config = [[NETunnelProviderProtocol alloc]init];
    config.providerBundleIdentifier = providerBundleIdentifier;
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

- (void)startVPN {
    NSError *error = nil;
    BOOL result = [_manager.connection startVPNTunnelWithOptions:nil andReturnError:&error];
    NSLog(@"manager %p, result %d, %@", _manager, result, error);
}

- (void)start {
    if (_manager) {
        return [self startVPN];
    }
    [self getManager:^(NETunnelProviderManager * _Nullable manager) {
        if (!manager) return NSLog(@"failed to get manager");

        _manager = manager;
        [self startVPN];
    }];
}

- (void)stop {
    [_manager.connection stopVPNTunnel];
    NSLog(@"%s", __FUNCTION__);
}

- (BOOL)connected {
    return _manager && _manager.connection.status == NEVPNStatusConnected;
}

- (void)monitorState:(StateChangeCallback)callback {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (callback) {
        _observer = [nc addObserverForName:NEVPNStatusDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            NETunnelProviderSession *session = note.object;
            NSLog(@"%p, %@", session, note.userInfo);
            callback(session.status == NEVPNStatusConnected);
        }];
    } else {
        [nc removeObserver:_observer];
    }
}

@end
