.default: plan

.PHONY: init plan apply output
init:
	terraform init
plan:
	terraform plan

apply:
	terraform apply

output:
	terraform output

.PHONY: ssh
ssh:
	ssh \
		-i $(shell terraform output -json | jq -r '.key_name.value').key \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/nul \
		root@$(shell terraform output -json | jq -r '.ec2_dns.value')

.PHONY: rsync/config
rsync/config:
	rsync -a \
		-e "ssh -i $(shell terraform output -json | jq -r '.key_name.value').key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/nul" \
		./ec2.nix root@$(shell terraform output -json | jq -r '.ec2_dns.value'):/etc/nixos/configuration.nix

