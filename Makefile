
CHECKASM := $(shell ls -l /usr/include/asm | awk '{if($$1 ~ "^l") print "OK";}')


build:
ifneq ($(CHECKASM), OK)
	sudo ln -s /usr/include/x86_64-linux-gnu/asm/ /usr/include/asm
endif
	clang -O2 -Wall -target bpf -c xdp_drop.c -o xdp_drop.o

attach: build
	sudo ip link set dev enp0s8 xdp obj xdp_drop.o

detach:
	sudo ip link set dev enp0s8 xdp off


#Show xdp in the enp0s8:
#sudo ip link show dev enp0s8