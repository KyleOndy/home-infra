{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  buildInputs = [
    nomad_1_0
    terraform_0_14

    # pre-commit
    # https://pre-commit.com/
    pre-commit
    detect-secrets
    shfmt
    ruby
  ];

  shellHook = ''
    export NOMAD_ADDR=http://10.25.89.20:4646
    export CONSUL_HTTP_ADDR=http://10.25.89.20:8500
    export AWS_ACCESS_KEY_ID="AKIAWLHJP4A2VKY63L4X"
    export AWS_SECRET_ACCESS_KEY="$(pass show aws.amazon.com/ondy-org/svc.home-infra/AKIAWLHJP4A2VKY63L4X)"
  '';
}
