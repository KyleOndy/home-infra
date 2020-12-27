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
    #nixpkgs.file = toString ./vendor/nixpkgs;
    "nixos-config.nix".file = toString ./configuration.worker.nix;
    "hardware-config.nix".file = toString ./hardware-configuration.nix;
  }];

  w1 = pkgs.krops.writeDeploy "deploy-w1" {
    source = source;
    target = "root@w1.dmz.509ely.com";
  };

  w2 = pkgs.krops.writeDeploy "deploy-w2" {
    source = source;
    target = "root@w2.dmz.509ely.com";
  };

  w3 = pkgs.krops.writeDeploy "deploy-w3" {
    source = source;
    target = "root@w3.dmz.509ely.com";
  };
in
{
  all = pkgs.writeScript "deploy-all-servers"
    (lib.concatStringsSep "\n" [ w1 w2 w3 ]);
}
