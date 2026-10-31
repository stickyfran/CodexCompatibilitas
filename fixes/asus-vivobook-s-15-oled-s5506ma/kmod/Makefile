obj-m += hid-asus-lamparray.o

KVER ?= $(shell uname -r)
KDIR ?= /usr/lib/modules/$(KVER)/build

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) LLVM=1 modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) LLVM=1 clean
