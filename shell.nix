{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # for building
    gnumake

    # for debugging
    lsof
    consul
    nomad
    fd
  ];
}

