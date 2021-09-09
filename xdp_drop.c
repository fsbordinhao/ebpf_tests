#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <arpa/inet.h>
#include <linux/ip.h>

__attribute__((section("prog"), used))
int xdp_drop(struct xdp_md *ctx)
{
	void *data_end = (void *)(long) ctx->data_end;
	void *data = (void *)(long) ctx->data;

	struct ethhdr *eth = data;

	uint64_t nh_off = sizeof(*eth);

	__u16 h_proto;

	if (data + sizeof(struct ethhdr) > data_end)
		return XDP_DROP;
	
	h_proto = eth->h_proto;

	if (h_proto == htons(ETH_P_IP)) {
		struct iphdr *iph = data + nh_off;

		if (data + sizeof(struct ethhdr) + sizeof(struct iphdr) > data_end)
			return XDP_DROP;

		if ( iph->protocol == IPPROTO_ICMP )
			return XDP_DROP;
		
	}


	return XDP_PASS;
}

char __license[] __attribute__((section("license"), used)) = "GPL";
