{ pkgs ? import <nixpkgs> { } }:

with pkgs;

stdenv.mkDerivation {
  name = "home_infra";

  buildInputs = [
    # hashi-stack
    nomad
    consul

    # pre-commit
    # https://pre-commit.com/
    pre-commit
    detect-secrets
    shfmt
    ruby
  ];

  shellHook = ''
    export NOMAD_ADDR=http://10.25.89.5:4646
    export DOCKER_HOST=ssh://ansible@c01w01.dmz.509ely.com
  '';
}
