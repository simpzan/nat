//
//  Utils.m
//  PacketTunnel
//
//  Created by simpzan on 07/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "Utils.h"

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
