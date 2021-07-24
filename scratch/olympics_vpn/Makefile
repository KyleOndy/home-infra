.PHONY: apply destroy plan-destroy plan prep get_opvn
VARS="variables/$(ENV)-$(REGION).tfvars"

plan:
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true

apply:
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true

destroy:
	@terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true

plan-destroy:
	@terraform plan \
		-input=false \
		-refresh=true \
		-destroy

prep:
	@terraform init \
		-input=false \
		-force-copy \
		-upgrade

get_opvn:
	rsync \
		-avrP \
		--protect-args \
		-e "ssh -o "StrictHostKeyChecking=no" -o UserKnownHostsFile=/dev/null -i $(shell terraform output --raw keypair)" \
		ubuntu@$(shell terraform output --raw vpn_ip):ovpn/ \
		./ovpn/
