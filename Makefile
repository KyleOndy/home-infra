CONSUL_ENCRYPT_KEY?=not_a_valid_consul_key
COMPRESSION_LEVEL=9
export PIXZ_COMPRESSION_LEVEL = ${COMPRESSION_LEVEL}

.PHONY: worker-node env

env:
	env | sort

worker-node:
	sudo -E ./node_builder/make_node ./dist ${CONSUL_ENCRYPT_KEY}
