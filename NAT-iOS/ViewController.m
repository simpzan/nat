//
//  ViewController.m
//  NAT-iOS
//
//  Created by simpzan on 12/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "ViewController.h"
#import "TunnelClient.h"
#import "ProxyServer.h"
#import "Utils.h"
#import "Config.h"
#import "UIViewController+ActionSheet.h"

NSString *providerBundleIdentifier = @"com.simpzan.NAT2.PacketTunnel2";

@interface ViewController () {
    TunnelClient *_client;
    ProxyServer *_proxy;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@end

@implementation ViewController
- (IBAction)toggleSwitch:(id)sender {
    NSLog(@"state %ld", self.switchButton.state);
    if ([_client connected]) {
        [_client stop];
    } else {
        [_client start];
    }
    
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
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
- (void)updateToggleState {
    self.switchButton.on = _client.connected ? UIControlStateSelected : UIControlStateNormal;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)containingAppTest:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [self select:@[@"routed ip", @"normal ip"] title:@"test from Containing app with" :^(int index) {
        if (index < 0) return;
        NSString *ipToTest = index == 0 ? routedIp : normalIp;
        test(ipToTest);
    }];
}
- (IBAction)extensionTest:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_client sendMessage:@"extension"];
}
- (IBAction)extensionTest2:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    [_client sendMessage:@"extension.createTCPConnectionThroughTunnelToEndpoint"];
}

@end
