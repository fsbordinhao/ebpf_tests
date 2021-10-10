
CHECKASM := $(shell ls -l /usr/include/asm | awk '{if($$1 ~ "^l") print "OK";}')


build_icmp_drop:
ifneq ($(CHECKASM), OK)
	sudo ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
endif
	clang \
		-I. -I../kernelsource/linux-hwe-5.11-5.11.0/tools/lib \
		-O2 -Wall -target bpf -c xdp_drop_icmp.c -o xdp_drop_icmp.o

build_firewall:
	clang -DPORT=$(port) -O2 -Wall -target bpf -c ebpf_firewall.c -o ebpf_firewall.o

attach_icmp_drop: build_icmp_drop
	sudo ip link set dev $(interface) xdp obj xdp_drop_icmp.o

detach_icmp_drop:
	sudo ip link set dev $(interface) xdp off

attach_firewall: build_firewall
	sudo tc qdisc add dev $(interface) clsact
	sudo tc filter add dev $(interface) ingress bpf da obj ebpf_firewall.o sec ebpf_firewall

dettach_firewall: 
	sudo tc qdisc del dev $(interface) clsact

clean:
	rm xdp_drop_icmp.o ebpf_firewall.o
