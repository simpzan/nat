//
//  Config.h
//  NAT
//
//  Created by simpzan on 08/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#ifndef Config_h
#define Config_h

#import <Foundation/Foundation.h>

static NSString *interfaceIp = @"10.25.1.1";
static NSString *remoteIp = @"10.25.1.2";
static NSString *dnsIp = @"114.114.114.114";
static NSString *netMask24 = @"255.255.255.0";
static NSString *netMask32 = @"255.255.255.255";

static NSString *routedIp = @"115.239.210.27";
static NSString *normalIp = @"61.135.169.121";

static NSString *fakeIp = @"10.25.1.100";
static NSString *proxyIp = @"10.25.1.1";
static NSString *proxyIp2 = @"127.0.0.1";
static uint16_t appProxyPort = 12345;
static uint16_t extensionProxyPort = 12344;
static uint16_t extensionProxyPort2 = 12343;

#endif /* Config_h */
