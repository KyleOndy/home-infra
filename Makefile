MAKE=make -j$(shell grep -c ^processor /proc/cpuinfo)
ARCH=x86
KERNEL_VERSION=5.12-rc2
NOMAD_VERSION=1.0.4
DIST_DIR=dist

vendor/linux-$(KERNEL_VERSION):
	rm -rf $@
	mkdir -p $(shell dirname $@)
# todo: this URL format only holds for this release
	wget -qO- https://git.kernel.org/torvalds/t/linux-$(KERNEL_VERSION).tar.gz | tar xzf - -C $(shell dirname $@)

vendor/nomad-$(NOMAD_VERSION):
	rm -rf $@
	mkdir -p $(shell dirname $@)
	wget -qO- https://github.com/hashicorp/nomad/archive/v$(NOMAD_VERSION).tar.gz | tar xzf - -C $(shell dirname $@)
	cd vendor/nomad-$(NOMAD_VERSION) && make GO_LDFLAGS+='"-extldflags=-static"' pkg/linux_amd64/nomad

$(DIST_DIR)/nomad: vendor/nomad-$(NOMAD_VERSION)
	cp vendor/nomad-$(NOMAD_VERSION)/pkg/linux_amd64/nomad $@

$(DIST_DIR)/vmlinuz: vendor/linux-$(KERNEL_VERSION)
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y defconfig
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y kvm_guest.config
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION) CONFIG_DEVTMPFS=y
	mkdir -p $(shell dirname $@)
	cp $</arch/$(ARCH)/boot/bzImage $@

$(DIST_DIR)/busybox:
	wget -q -O $@ https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
	chmod +x $@

$(DIST_DIR)/init: myinit.c
	gcc -static myinit.c -o $@

vendor/linux/arch/x86_64/boot/bzImage:
	cd vendor/linux && \
		$(MAKE) defconfig && \
		$(MAKE) kvm_guest.config && \
		$(MAKE)

$(DIST_DIR)/initramfs.cpio: mk_initramfs $(DIST_DIR)/init $(DIST_DIR)/nomad $(DIST_DIR)/busybox
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
