//
//  DNSMessage.m
//  NAT
//
//  Created by simpzan on 25/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import "DNSMessage.h"

typedef struct dnshdr {
    char id[2];
    char flags[2];
    char qdcount[2];
    char ancount[2];
    char nscount[2];
    char arcount[2];
} DNSHeader;
typedef struct dnsquery {
    char *qname;
    char qtype[2];
    char qclass[2];
} DNSQuery;
typedef struct dnsanswer {
    char *name;
    char atype[2];
    char aclass[2];
    char ttl[4];
    char RdataLen[2];
    char *Rdata;
} DNSAnswer;

NSString *decodeDomainName(const uint8_t *query){
    char request[1024];
    unsigned int i, j, k;
    const uint8_t *curr = query;
    
    uint32_t size = curr[0];
    
    j=0;
    i=1;
    while(size > 0){
        for(k=0; k<size; k++){
            request[j++] = curr[i+k];
        }
        request[j++]='.';
        i+=size;
        size = curr[i++];
    }
    request[--j] = '\0';
    return [[NSString alloc]initWithUTF8String:request];
}

@implementation DNSMessage

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    
    const uint8_t *bytes = data.bytes + sizeof(DNSHeader);
    _queryName = decodeDomainName(bytes);
    
    return self;
}

- (NSString *)queryName {
    return _queryName;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"DNS request %@", _queryName];
}

@end
