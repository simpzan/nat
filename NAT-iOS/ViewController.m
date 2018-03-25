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
    NSLog(@"state %d", (int)self.switchButton.state);
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
    NSArray *actions = @[@"routed ip, NSString", @"normal ip, NSString", @"routed ip, Socket", @"normal ip, Socket", @"routed ip, udp", @"normal ip, udp", @"dns"];
    [self select:actions title:@"test from Containing app with" :^(int index) {
        if (index < 0) return;
        NSString *ipToTest = index % 2 == 0 ? routedIp : normalIp;
        if (index < 2) {
            test(ipToTest);
        } else if (index < 4) {
            httpRequestGCDAsyncSocket(ipToTest, 80);
        } else if (index < 6) {
            udpSend([ipToTest cStringUsingEncoding:NSUTF8StringEncoding], 16383, "hello udp");
        } else {
            dnsTest("www.taobao.com");
        }
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
