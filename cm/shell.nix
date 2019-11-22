# This imports the nix package collection,
# so we can access the `pkgs` and `stdenv` variables
with import <nixpkgs> {};

# Make a new "derivation" that represents our shell
stdenv.mkDerivation {
  name = "my-environment";

  # The packages in the `buildInputs` list will be added to the PATH in our shell
  buildInputs = [
    pkgs.ansible
    pkgs.sshpass
    pkgs.python38Packages.setuptools
    pkgs.python38Packages.pip
    pkgs.python38Packages.netaddr
  ];
}
