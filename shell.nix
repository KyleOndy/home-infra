{ pkgs ? import <nixpkgs> { } }:

with pkgs;

stdenv.mkDerivation {
  name = "home_infra";

  buildInputs = [
    debootstrap

    # pre-commit
    # https://pre-commit.com/
    pre-commit
    detect-secrets
    shfmt
    ruby
  ];

  shellHook = ''
    export NOMAD_ADDR=http://10.25.89.10:4646
    export CONSUL_ADDR=http://10.25.89.10:8500
  '';
}
