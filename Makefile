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




.PHONY: docker-build-env
docker-build-env: Dockerfile.build_env
	docker build -t build_env:latest -f Dockerfile.build_env .

.PHONY: docker-kernel-build
docker-kernel-build: Dockerfile.kernel_build
	docker build -t kernel_build:latest -f Dockerfile.kernel_build .

myinit: myinit.c
	gcc -static myinit.c -o myinit

vendor/linux/arch/x86_64/boot/bzImage:
	cd vendor/linux && \
		$(MAKE) defconfig && \
		$(MAKE) kvm_guest.config && \
		$(MAKE)

.PHONY: clean
clean:
	rm -rf $(DIST_DIR)
