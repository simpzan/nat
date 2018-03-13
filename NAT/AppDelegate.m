//
//  AppDelegate.m
//  NAT
//
//  Created by simpzan on 05/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "AppDelegate.h"
#import "TunnelClient.h"
#import "ProxyServer.h"
#import "Utils.h"
#import "Config.h"

NSString *providerBundleIdentifier = @"com.simpzan.NAT.PacketTunnel";

@interface AppDelegate () {
    TunnelClient *_client;
    ProxyServer *_proxy;
}

@property (weak) IBOutlet NSButtonCell *toggleSwitch;
@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _client = [[TunnelClient alloc]init];
    _proxy = [[ProxyServer alloc]init];

    [_client start];
    [_client monitorState:^(BOOL state) {
        if (state) {
            [_proxy startWithAddress:proxyIp port:appProxyPort];
        } else {
            [_proxy stop];
        }
        [self updateToggleState];
    }];
    [self updateToggleState];
    NSLog(@"start");
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [_client stop];
    [_proxy stop];

    NSLog(@"stop");
}

- (IBAction)toggle:(id)sender {
    NSLog(@"state %ld", self.toggleSwitch.state);
    if ([_client connected]) {
        [_client stop];
    } else {
        [_client start];
    }
}
- (IBAction)extensionTest:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}
- (IBAction)containingAppTest:(id)sender {
    NSLog(@"%s", __FUNCTION__);
}
- (void)updateToggleState {
    self.toggleSwitch.state = _client.connected ? NSControlStateValueOn : NSControlStateValueOff;
}

@end
