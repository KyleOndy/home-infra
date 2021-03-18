DOCKER_HOST=unix:///var/run/docker.sock
# 9 is max, good for deployment, set to 0 for dev
COMPRESSION_LEVEL=9
DIST_DIR=dist

# I noramlly like the `+changes` naming, but the `+` chracter is invlaid in
# docker tags.
CHANGES:=$(shell git diff-index HEAD --)
ifneq ($(CHANGES),)
GIT_CHANGES:=-changes
endif
GIT_REV:=$(shell git rev-parse --short HEAD)$(GIT_CHANGES)

# can't use ISO-8601 due to `:` in file paths
BUILD_TIMESTAMP:=$(date --utc +%Y-%m-%d_%H%M%S)
# todo: mask this in the logs?
CONSUL_ENCRYPT_KEY:=$(shell pass show 509ely.com/consul_encryption_key)

DOCKER=docker --host=$(DOCKER_HOST)
# todo: don't pass all args to all contianers. This _is_ a security issue, but
# since I control the build, I am not too worried right now.
DOCKER_BUILD=$(DOCKER) build \
                   --pull \
                   --build-arg=CONSUL_ENCRYPT_KEY=$(CONSUL_ENCRYPT_KEY) \
                   --build-arg=COMMIT=$(GIT_REV) \
                   --build-arg=BUILD_TIMESTAMP=$(shell date --utc --iso-8601=seconds)

# I feel like there is a lot of dupliction here, but I am rolling with it for
# now until I am sure this is the direction I want to go.
KERNEL_WORKER_IMAGE=worker.kernel:$(GIT_REV)
RAMROOT_WORKER_IMAGE=worker.ramroot:$(GIT_REV)

export PIXZ_COMPRESSION_LEVEL = ${COMPRESSION_LEVEL}

.PHONY: worker-node
ROLE=worker
ARCH=amd64
worker-node: $(DIST_DIR)/$(ROLE)/$(ARCH)/vmlinuz
worker-node: $(DIST_DIR)/$(ROLE)/$(ARCH)/initrd.img
worker-node: $(DIST_DIR)/$(ROLE)/$(ARCH)/ramroot.tar.xz

.PHONY: $(DIST_DIR)/worker/$(ARCH)/vmlinuz
$(DIST_DIR)/worker/$(ARCH)/vmlinuz: $(DIST_DIR)/worker/$(ARCH)/vmlinuz.$(GIT_REV)
	ln -srf $< $@

.PHONY: $(DIST_DIR)/worker/$(ARCH)/initrd.img
$(DIST_DIR)/worker/$(ARCH)/initrd.img: $(DIST_DIR)/worker/$(ARCH)/initrd.img.$(GIT_REV)
	ln -srf $< $@

.PHONY: $(DIST_DIR)/worker/$(ARCH)/ramroot.tar.xz
$(DIST_DIR)/worker/$(ARCH)/ramroot.tar.xz: $(DIST_DIR)/worker/$(ARCH)/ramroot.tar.xz.$(GIT_REV)
	ln -srf $< $@

.PHONY: docker-worker-kernel
docker-worker-kernel:
	$(DOCKER_BUILD) -f Dockerfile.worker.kernel -t $(KERNEL_WORKER_IMAGE) .

.PHONY: docker-worker-ramroot
docker-worker-ramroot:
	$(DOCKER_BUILD) -f Dockerfile.worker.ramroot -t $(RAMROOT_WORKER_IMAGE) .

$(DIST_DIR)/worker/$(ARCH)/vmlinuz.$(GIT_REV): | docker-worker-kernel
	@mkdir -p $(@D)
	@# using GIT_REV as container name
	@$(DOCKER) rm -f $(GIT_REV)
	$(DOCKER) run --name $(GIT_REV) --rm -d $(KERNEL_WORKER_IMAGE) bash -c "sleep 600"
	$(DOCKER) cp -L $(GIT_REV):/boot/vmlinuz $@
	$(DOCKER) rm -f $(GIT_REV)
	chmod 755 $@

$(DIST_DIR)/worker/$(ARCH)/initrd.img.$(GIT_REV): | docker-worker-kernel
	@mkdir -p $(@D)
	@# using GIT_REV as container name
	@$(DOCKER) rm -f $(GIT_REV)
	$(DOCKER) run --name $(GIT_REV) --rm -d $(KERNEL_WORKER_IMAGE) bash -c "sleep 600"
	$(DOCKER) cp -L $(GIT_REV):/boot/initrd.img $@
	$(DOCKER) rm -f $(GIT_REV)
	chmod 755 $@

$(DIST_DIR)/worker/$(ARCH)/ramroot.tar.xz.$(GIT_REV): | docker-worker-ramroot
	@mkdir -p $(@D)
	@# using GIT_REV as container name
	@$(DOCKER) rm -f $(GIT_REV)
	$(DOCKER) run --name $(GIT_REV) --rm -d $(RAMROOT_WORKER_IMAGE) bash -c "sleep 600"
	$(DOCKER) export $(GIT_REV) | pixz -${COMPRESSION_LEVEL} > $@
	$(DOCKER) rm -f $(GIT_REV)
	chmod 755 $@

.PHONY: clean
clean:
	[ -d $(DIST_DIR) ] && rm -rf $(DIST_DIR)/*
