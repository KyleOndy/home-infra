.PHONY: deploy
deploy:
	./deploy

.PHONY: aws-infra
aws-infra:
	make --directory=tf init apply
