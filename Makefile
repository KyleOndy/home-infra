deploy:
	nix run github:serokell/deploy-rs . -- --interactive --magic-rollback false

deploy-auto:
	nix run github:serokell/deploy-rs . -- --magic-rollback false
