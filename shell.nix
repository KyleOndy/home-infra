{ pkgs ? import <nixpkgs> { } }:

with pkgs;

stdenv.mkDerivation {
  name = "home_infra";

  buildInputs = [
    # kernel building
    bison
    fakeroot
    flex
    gcc
    glibc
    glibc.static
    openssl
    elfutils
    libelf

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
