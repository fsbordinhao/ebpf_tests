#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <arpa/inet.h>

__attribute__((section("ebpf_firewall"), used))
int drop_specific_port(struct __sk_buff *skb) {
    const int network_offset = ETH_HLEN;
    const int transport_offset = network_offset + sizeof(struct iphdr);
    const int application_oofset = transport_offset + sizeof(struct tcphdr);

    void *data = (void*)(long)skb->data;
    void *data_end = (void*)(long)skb->data_end;

    if (data_end < data + application_oofset)
        return TC_ACT_OK;

    struct ethhdr *eth = data;
    if (eth->h_proto != htons(ETH_P_IP))
       return TC_ACT_OK;

    struct iphdr *ip = (struct iphdr *)(data + network_offset);
    if (ip->protocol != IPPROTO_TCP)
        return TC_ACT_OK;

    struct tcphdr *tcp = (struct tcphdr *)(data + transport_offset);
    if (ntohs(tcp->dest) != PORT)
        return TC_ACT_OK;

    return TC_ACT_SHOT;
}

