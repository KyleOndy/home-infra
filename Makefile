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
	./node_builder/make ./node_builder/dist
	sudo chown $(shell whoami) -R ./node_builder/dist
	sudo chmod -R 755 ./node_builder/dist

.PHONY: move_artifacts
move_artifacts:
	mkdir -p ./util-node/files/worker/amd64
	sudo cp ./node_builder/dist/initrd.img     ./util-node/files/worker/amd64/initrd.img
	sudo cp ./node_builder/dist/ramroot.tar.xz ./util-node/files/worker/amd64/ramroot.tar.xz
	sudo cp ./node_builder/dist/vmlinuz        ./util-node/files/worker/amd64/vmlinuz
