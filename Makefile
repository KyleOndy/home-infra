CONSUL_ENCRYPT_KEY?=not_a_valid_consul_key
COMPRESSION_LEVEL=9
export PIXZ_COMPRESSION_LEVEL = ${COMPRESSION_LEVEL}

.PHONY: worker-node worker-node-ramroot env

env:
	env | sort

worker-node: $(shell fd --type=file . ./node_builder)
	nix-shell --command "PIXZ_COMPRESSION_LEVEL=$(COMPRESSION_LEVEL) sudo -E ./node_builder/make_node --initramfs --ramroot"

worker-node-ramroot: $(shell fd --type=file . ./node_builder)
	nix-shell --command "PIXZ_COMPRESSION_LEVEL=$(COMPRESSION_LEVEL) sudo -E ./node_builder/make_node --ramroot"
