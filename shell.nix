{ pkgs ? import <nixpkgs> { } }:

with pkgs;

stdenv.mkDerivation {
  name = "home_infra";

  buildInputs = [
    debootstrap
    fakechroot
    fakeroot

    # pre-commit
    # https://pre-commit.com/
    pre-commit
    detect-secrets
    shfmt
    ruby
  ];

  shellHook = ''
  '';
}
