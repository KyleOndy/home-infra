deploy/w1:


deploy/all:
	nix run github:serokell/deploy-rs . -- --interactive

deploy/all-auto:
	nix run github:serokell/deploy-rs . --

update/all:
	nix flake update --recreate-lock-file

update/nixpkgs:
	nix flake update --update-input nixpkgs

update/deploy-rs:
	nix flake update --update-input deploy-rs

k3s-config:
	@rsync -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" root@10.25.89.5:/etc/rancher/k3s/k3s.yaml .
