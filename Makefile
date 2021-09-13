
CHECKASM := $(shell ls -l /usr/include/asm | awk '{if($$1 ~ "^l") print "OK";}')


build:
ifneq ($(CHECKASM), OK)
	sudo ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
endif
	clang \
		-I. -I../kernelsource/linux-hwe-5.11-5.11.0/tools/lib \
		-O2 -Wall -target bpf -c xdp_drop_icmp.c -o xdp_drop_icmp.o

attach: build
	sudo ip link set dev $(interface) xdp obj xdp_drop_icmp.o

detach:
	sudo ip link set dev $(interface) xdp off

clean:
	rm xdp_drop_icmp.o
