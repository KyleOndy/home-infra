{ pkgs ? import <nixpkgs> { } }:

with pkgs;
mkShell {
  buildInputs = [
    # pre-commit
    # https://pre-commit.com/
    pre-commit
    detect-secrets
    shfmt
    ruby
  ];

  shellHook = ''
    export NOMAD_ADDR=http://10.25.89.20:4646
    export CONSUL_ADDR=http://10.25.89.20:8500
  '';
}
