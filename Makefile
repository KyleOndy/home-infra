MAKE=make -j$(shell grep -c ^processor /proc/cpuinfo)
ARCH=x86
KERNEL_VERSION=5.12-rc2
NOMAD_VERSION=1.0.4
DIST_DIR=dist
VENDOR_DIR=vendor

$(VENDOR_DIR)/linux-$(KERNEL_VERSION):
	rm -rf $@
	mkdir -p $(shell dirname $@)
# todo: this URL format only holds for this release
	wget -qO- https://git.kernel.org/torvalds/t/linux-$(KERNEL_VERSION).tar.gz | tar xzf - -C $(shell dirname $@)

$(VENDOR_DIR)/nomad-$(NOMAD_VERSION):
	rm -rf $@
	mkdir -p $(shell dirname $@)
	wget -qO- https://github.com/hashicorp/nomad/archive/v$(NOMAD_VERSION).tar.gz | tar xzf - -C $(shell dirname $@)
	cd $(VENDOR_DIR)/nomad-$(NOMAD_VERSION) && make GO_LDFLAGS+='"-extldflags=-static"' pkg/linux_amd64/nomad

$(DIST_DIR)/nomad: $(VENDOR_DIR)/nomad-$(NOMAD_VERSION)
	mkdir -p $(shell dirname $@)
	cp $(VENDOR_DIR)/nomad-$(NOMAD_VERSION)/pkg/linux_amd64/nomad $@

$(DIST_DIR)/vmlinuz: $(VENDOR_DIR)/linux-$(KERNEL_VERSION)
	mkdir -p $(shell dirname $@)
	$(MAKE) -C $(VENDOR_DIR)/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y defconfig
	$(MAKE) -C $(VENDOR_DIR)/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y kvm_guest.config
	$(MAKE) -C $(VENDOR_DIR)/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y
	mkdir -p $(shell dirname $@)
	cp $</arch/$(ARCH)/boot/bzImage $@

$(DIST_DIR)/busybox:
	mkdir -p $(shell dirname $@)
	wget -q -O $@ https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
	chmod +x $@

$(DIST_DIR)/init: myinit.c
	mkdir -p $(shell dirname $@)
	gcc -static myinit.c -o myinit
	mv myinit $@

$(VENDOR_DIR)/linux/arch/x86_64/boot/bzImage:
	cd $(VENDOR_DIR)/linux && \
		$(MAKE) defconfig && \
		$(MAKE) kvm_guest.config && \
		$(MAKE)

$(DIST_DIR)/initramfs.cpio: mk_initramfs $(DIST_DIR)/init $(DIST_DIR)/vmlinuz $(DIST_DIR)/nomad $(DIST_DIR)/busybox
	./mk_initramfs
	mv initramfs.cpio $@

.PHONY: run-qemu
run-qemu:
	qemu-system-x86_64 \
		-kernel $(DIST_DIR)/vmlinuz \
		-initrd $(DIST_DIR)/initramfs.cpio \
		-nographic \
		-m 1G \
		-append "console=ttyS0"

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)
	rm -rf $(VENDOR_DIR)
