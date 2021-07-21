.PHONY: apply destroy plan-destroy plan prep
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
