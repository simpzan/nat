//
//  Utils.m
//  PacketTunnel
//
//  Created by simpzan on 07/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <ifaddrs.h>
#import <net/if.h>
#import <arpa/inet.h>
#import "Utils.h"
#import "GCDAsyncSocket.h"

NSString *getIfName(NSString *ip) {
    struct ifaddrs *interfaces = NULL;
    NSInteger result = getifaddrs(&interfaces);
    if (result != 0) {
        NSLog(@"getifaddrs error, %s", strerror(errno));
        return NULL;
    }

    NSString *ifName = NULL;
    for (struct ifaddrs *itr = interfaces; itr; itr = itr->ifa_next) {
        if (itr->ifa_addr->sa_family != AF_INET) continue;

        NSString* ifaName = [NSString stringWithUTF8String:itr->ifa_name];
        NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) itr->ifa_addr)->sin_addr)];
//        NSString* mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) itr->ifa_netmask)->sin_addr)];
//        NSString* gateway = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) itr->ifa_dstaddr)->sin_addr)];
//        NSLog(@"%@;%@;%@;%@",ifaName,address,mask,gateway);
        if ([address isEqualToString:ip]) {
            ifName = ifaName;
            break;
        }
    }
    freeifaddrs(interfaces);
    return ifName;
}
int boundInterface(int socket, NSString *address) {
    NSString *name = getIfName(address);
    if (!name) {
        return -1;
    }

    int ifIndex = if_nametoindex([name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (ifIndex == 0) {
        NSLog(@"if_nametoindex error, %s", strerror(errno));
        return -1;
    }

    int status = setsockopt(socket, IPPROTO_IP, IP_BOUND_IF, &ifIndex, sizeof(ifIndex));
    if (status == -1) {
        NSLog(@"setsockopt IP_BOUND_IF error, %s", strerror(errno));
        return -1;
    }
    NSLog(@"set IP_BOUND_IF ok");
    return 0;
}
NSString *getAddress(const void *data) {
    char str[128] = {0};
    const char *result = inet_ntop(AF_INET, data, str, sizeof(str));
    if (!result) {
        NSLog(@"inet_ntop failed, %s", strerror(errno));
        return nil;
    }
    return [NSString stringWithUTF8String:result];
}
void setAddress(void *data, NSString *address) {
    int result = inet_pton(AF_INET, [address UTF8String], data);
    if (result != 1) {
        NSLog(@"inet_pton(%@) failed , %s", address, strerror(errno));
    }
}

uint16_t getPort(const void *data) {
    uint16_t result = *(const uint16_t *)data;
    return ntohs(result);
}
void setPort(void *data, uint16_t port) {
    uint16_t *result = (uint16_t *)data;
    *result = htons(port);
}


void delay(double delayInSeconds, void(^callback)(void)){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(callback){
            callback();
        }
    });
}

void test(NSString *ip) {
    NSLog(@"%s %@", __FUNCTION__, ip);
    NSString *url = [[NSString alloc]initWithFormat:@"http://%@", ip];
    NSError *err = nil;
    NSString *response =  [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"response %@, %@", response, err);
}

NSString *getContainingAppId() {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundleId = bundle.bundleIdentifier;
    if (bundle.infoDictionary[@"NSExtension"]) {
        bundleId = [bundleId stringByDeletingPathExtension];
    }
    return bundleId;
}

NSString *getSharedAppGroupId() {
    NSString *bundleId = getContainingAppId();
    return [@"group." stringByAppendingString:bundleId];
}

@implementation NSArray(Functional)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:block(obj, idx)];
    }];
    return result;
}
- (id)findFirstObjectUsingBlock:(BOOL (^)(id ojb, NSUInteger idx))predicate {
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (predicate(obj, idx)) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}
- (void)test{
    NSArray<NSNumber *> * a = @[@1, @2];
    [a findFirstObjectUsingBlock:^BOOL(id obj, NSUInteger idx) {
        return YES;
    }];
}
@end

@implementation NSData(Hex)
- (NSString*)hexRepresentation {
    BOOL spaces = YES;
    const unsigned char* bytes = (const unsigned char*)[self bytes];
    NSUInteger nbBytes = [self length];
    //If spaces is true, insert a space every this many input bytes (twice this many output characters).
    static const NSUInteger spaceEveryThisManyBytes = 4UL;
    //If spaces is true, insert a line-break instead of a space every this many spaces.
    static const NSUInteger lineBreakEveryThisManySpaces = 4UL;
    const NSUInteger lineBreakEveryThisManyBytes = spaceEveryThisManyBytes * lineBreakEveryThisManySpaces;
    NSUInteger strLen = 2*nbBytes + (spaces ? nbBytes/spaceEveryThisManyBytes : 0);

    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for (NSUInteger i=0; i<nbBytes; ) {
        [hex appendFormat:@"%02X", bytes[i]];
        //We need to increment here so that the every-n-bytes computations are right.
        ++i;

        if (spaces) {
            if (i % lineBreakEveryThisManyBytes == 0) [hex appendString:@"\n"];
            else if (i % spaceEveryThisManyBytes == 0) [hex appendString:@" "];
        }
    }
    return hex;
}
@end



#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

#include <netinet/tcp.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netdb.h>

int socket_connect(const char *host, in_port_t port){
    struct hostent *hp;
    struct sockaddr_in addr;
    int on = 1, sock;

    if((hp = gethostbyname(host)) == NULL){
        herror("gethostbyname");
        exit(1);
    }
    bcopy(hp->h_addr, &addr.sin_addr, hp->h_length);
    addr.sin_port = htons(port);
    addr.sin_family = AF_INET;
    sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (const char *)&on, sizeof(int));

    if(sock == -1){
        perror("setsockopt");
        exit(1);
    }

    if(connect(sock, (struct sockaddr *)&addr, sizeof(struct sockaddr_in)) == -1){
        perror("connect");
        exit(1);

    }
    return sock;
}

#define BUFFER_SIZE 1024

int httpRequestSocket(const char *host, uint16_t port) {
    char buffer[BUFFER_SIZE];

    int fd = socket_connect(host, port);
    const char *requstHeader = "GET / HTTP/1.1\r\nConnection: close\r\n\r\n";
    write(fd, requstHeader, strlen(requstHeader));
    bzero(buffer, BUFFER_SIZE);

    int64_t result;
    while(true) {
        result = read(fd, buffer, BUFFER_SIZE - 1);
        if (result < 0) {
            NSLog(@"read error, %s", strerror(errno));
            break;
        }
        if (result == 0) {
            NSLog(@"eof");
            break;
        }
        NSLog(@"%s", buffer);
        bzero(buffer, BUFFER_SIZE);
    }

    shutdown(fd, SHUT_RDWR);
    close(fd);

    return 0;
}


@interface GCDAsyncSocket(HttpTest) <GCDAsyncSocketDelegate>
@end

GCDAsyncSocket *sock;

@implementation GCDAsyncSocket(HttpTest)

+ (void)httpRequest:(NSString *)host :(uint16_t)port {
    sock = [[GCDAsyncSocket alloc]init];
    [sock setDelegate:sock delegateQueue:dispatch_get_main_queue()];
    NSError *err;
    BOOL result = [sock connectToHost:host onPort:port error:&err];
    if (!result) {
        NSLog(@"http request error, %@", err);
        return;
    }
    const char *requstHeader = "GET / HTTP/1.1\r\nConnection: close\r\n\r\n";
    NSData *data = [[NSData alloc] initWithBytes:requstHeader length:strlen(requstHeader)];
    [sock writeData:data withTimeout:-1 tag:55];
    [sock readDataWithTimeout:-1 tag:56];
    NSLog(@"%s %@", __FUNCTION__, host);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"%s %@", __FUNCTION__, host);
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"%s %ld", __FUNCTION__, tag);
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@", __FUNCTION__, str);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"%s %@", __FUNCTION__, err);
    sock = nil;
}

@end

void httpRequestGCDAsyncSocket(NSString *host, uint16_t port) {
    return [GCDAsyncSocket httpRequest:host :port];
}

#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>

#ifndef   NI_MAXHOST
#define   NI_MAXHOST 1025
#endif

void dnsTest(const char *domain) {
    struct addrinfo *result;
    struct addrinfo *res;
    int error;

    /* resolve the domain name into a list of addresses */
    error = getaddrinfo(domain, NULL, NULL, &result);
    if (error != 0)
    {
        NSLog(@"error in getaddrinfo: %s\n", gai_strerror(error));
        return;
    }

    /* loop over all returned results and do inverse lookup */
    for (res = result; res != NULL; res = res->ai_next)
    {
        char hostname[NI_MAXHOST] = "";

        error = getnameinfo(res->ai_addr, res->ai_addrlen, hostname, NI_MAXHOST, NULL, 0, 0);
        if (error != 0)
        {
            NSLog(@"error in getnameinfo: %s\n", gai_strerror(error));
            continue;
        }
        if (*hostname != '\0')
            NSLog(@"hostname: %s\n", hostname);
    }

    freeaddrinfo(result);
    return;
}

#include <netdb.h>
#include <stdio.h>

void udpSend(const char *address, uint16_t port, const char *msg) {
    int s;
    struct sockaddr_in server;
    
    /* Create a datagram socket in the internet domain and use the
     * default protocol (UDP).
     */
    if ((s = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        NSLog(@"socket()");
        return;
    }
    
    /* Set up the server name */
    server.sin_family      = AF_INET;            /* Internet Domain    */
    server.sin_port        = port;               /* Server Port        */
    server.sin_addr.s_addr = inet_addr(address); /* Server's Address   */
    
    /* Send the message in buf to the server */
    if (sendto(s, msg, (strlen(msg)+1), 0,
               (struct sockaddr *)&server, sizeof(server)) < 0) {
        NSLog(@"sendto()");
        return;
    }
    
    /* Deallocate the socket */
    close(s);
    NSLog(@"udpSend %s:%d, %s", address, port, msg);
}
