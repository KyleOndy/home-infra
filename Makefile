# todo:
#       - check ARCH

# todo: do I need this?
#.SECONDEXPANSION:

CONSUL_ENCRYPT_KEY?=not_a_valid_consul_key
# 9 is max, good for deployment, set to 0 for dev
COMPRESSION_LEVEL=9
DIST_DIR=./dist
.PHONY: env
env:
	env | sort

.PHONY: run-qemu
run-qemu: worker-node
	./scripts/run-qemu.sh $(DIST_DIR)/vmlinuz $(DIST_DIR)/initrd.img $(DIST_DIR)/ramroot.tar.xz
