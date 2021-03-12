MAKE=make -j$(shell grep -c ^processor /proc/cpuinfo)
ARCH=x86
KERNEL_VERSION=5.12-rc2
DIST_DIR=dist

vendor/linux-$(KERNEL_VERSION):
	rm -rf $@
	mkdir -p $(shell dirname $@)
# todo: this URL format only holds for this release
	wget -qO- https://git.kernel.org/torvalds/t/linux-$(KERNEL_VERSION).tar.gz | tar xzf - -C $(shell dirname $@)

$(DIST_DIR)/vmlinuz: vendor/linux-$(KERNEL_VERSION)
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION) defconfig
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION) kvm_guest.config
	$(MAKE) -C vendor/linux-$(KERNEL_VERSION)
	mkdir -p $(shell dirname $@)
	cp $</arch/$(ARCH)/boot/bzImage $@

$(DIST_DIR)/init: myinit.c
	gcc -static myinit.c -o $@

vendor/linux/arch/x86_64/boot/bzImage:
	cd vendor/linux && \
		$(MAKE) defconfig && \
		$(MAKE) kvm_guest.config && \
		$(MAKE)

$(DIST_DIR)/initramfs.cpio: mk_initramfs $(DIST_DIR)/init
	./mk_initramfs $(DIST_DIR)/init
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
