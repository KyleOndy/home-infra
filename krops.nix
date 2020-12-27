let
  krops = (import <nixpkgs> { }).fetchgit {
    url = https://cgit.krebsco.de/krops/;
    rev = "v1.17.0";
    sha256 = "150jlz0hlb3ngf9a1c9xgcwzz1zz8v2lfgnzw08l3ajlaaai8smd";
  };
  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" { };

  # todo: use niv
  source = lib.evalSource [{
    nixpkgs.git = {
      clean.exclude = [ "/.version-suffix" ];
      ref = "4b4bbce199d3b3a8001ee93495604289b01aaad3";
      url = https://github.com/NixOS/nixpkgs;
    };
    nixos-config.file = toString ./configuration.worker.nix;
  }
    {
      config.file = toString ./hardware-configuration.nix;
      nix-config.symlink = "config/hardware-configuration.nix";
    }];

in
{
  w1 = pkgs.krops.writeDeploy "deploy-w1" {
    source = source;
    target = "root@w1.dmz.509ely.com";
  };
}
