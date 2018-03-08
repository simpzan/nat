//
//  Checksum.m
//  PacketTunnel
//
//  Created by simpzan on 08/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <netinet/tcp.h>
#import <netinet/ip.h>
#import "Checksum.h"

typedef struct ip iphdr;
typedef struct tcphdr tcphdr;

static uint16_t foldChecksum(uint64_t sum) {
    while (sum >> 16) {
        sum = (sum & 0xffff) + (sum >> 16);
    }
    return sum;
}
static uint64_t sumBytes(const void *bytes, int count) {
    uint16_t *addr = (uint16_t *)bytes;
    register uint64_t sum = 0;
    while (count > 1) {
        sum += *addr;
        addr++;
        count -= 2;
    }
    if (count > 0) {
        sum += (*addr) & htons(0xFF00);
    }
    return sum;
}

uint64_t computePseudoHeaderChecksum(iphdr *pIph) {
    register uint64_t sum = 0;

    uint16_t *ip_src = (uint16_t *)&(pIph->ip_src);
    sum += ip_src[0];
    sum += ip_src[1];

    uint16_t *ip_dst = (uint16_t *)&(pIph->ip_dst);
    sum += ip_dst[0];
    sum += ip_dst[1];

    sum += htons(IPPROTO_TCP);

    uint16_t tcpLen = ntohs(pIph->ip_len) - (pIph->ip_hl<<2);
    sum += htons(tcpLen);

    return sum;
}

/* set ip checksum of a given ip header*/
void computeIpChecksum(uint8_t *bytes){
    iphdr *iphdrp = (iphdr *)bytes;
    iphdrp->ip_sum= 0;
    uint64_t sum = sumBytes(bytes, iphdrp->ip_hl<<2);
    iphdrp->ip_sum = ~foldChecksum(sum);
}


/* set tcp checksum: given IP header and tcp segment */
void computeTcpChecksum(uint8_t *bytes) {
    iphdr *pIph = (iphdr *)bytes;
    register uint64_t pseudoHeaderSum = computePseudoHeaderChecksum(pIph);

    uint16_t ipHeaderLen = pIph->ip_hl * 4;
    tcphdr *tcphdrp = (tcphdr *)(bytes + ipHeaderLen);
    tcphdrp->th_sum = 0;
    uint16_t tcpLen = ntohs(pIph->ip_len) - ipHeaderLen;
    uint64_t payloadSum = sumBytes(tcphdrp, tcpLen);

    tcphdrp->th_sum = ~foldChecksum(payloadSum + pseudoHeaderSum);
}

void computeChecksums(uint8_t *bytes) {
    computeIpChecksum(bytes);
    computeTcpChecksum(bytes);
}

