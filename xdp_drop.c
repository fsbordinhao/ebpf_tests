#include <linux/bpf.h>

__attribute__((section("prog"), used))
int xdp_drop(struct xdp_md *ctx)
{
	return XDP_DROP;
}

char __license[] __attribute__((section("license"), used)) = "GPL";
