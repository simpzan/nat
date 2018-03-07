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
    [self updateToggleState];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)toggle:(id)sender {
    NSLog(@"state %ld", self.toggleSwitch.state);
    if ([_client connected]) {
        [_client stop];
        [_proxy stop];
    } else {
        [_client start];
        
        delay(3, ^{
            [_proxy startWithAddress:@"10.25.1.1" port:12345];
        });
    }
}
- (void)updateToggleState {
    self.toggleSwitch.state = _client.connected ? NSControlStateValueOn : NSControlStateValueOff;
}

@end
