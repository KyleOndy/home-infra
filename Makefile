# if this is not set to a valid key (use `consul keygen`) the node will build,
# but consul will not start if you try to run the node.
CONSUL_ENCRYPT_KEY?=not_a_valid_consul_key

# pixz can compress between 0 (nothing) and 9 (MAX!). 0 is best for iteration,
# use a high value for production builds.
COMPRESSION_LEVEL=9

.PHONY: worker-node env

env:
	env | sort

worker-node:
	sudo -E ./node_builder/make_node ./dist ${CONSUL_ENCRYPT_KEY}

# todo: use filesnames
.PHONY: artifcats
artifcats:
	mkdir -p ./dist/server/arm64
	./node_builder/make ./node_builder/dist
	cp ./node_builder/dist/initrd.img     ./dist/server/arm64/initrd.img
	cp ./node_builder/dist/ramroot.tar.xz ./dist/server/arm64/ramroot.tar.xz
	cp ./node_builder/dist/vmlinuz        ./dist/server/arm64/vmlinuz
