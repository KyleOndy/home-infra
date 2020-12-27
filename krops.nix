let
  krops = (import <nixpkgs> { }).fetchgit {
    url = https://cgit.krebsco.de/krops/;
    rev = "v1.23.0";
    sha256 = "1yn8ym1rvvdfzmc64gjzw7dg2cs8prvgmdzxk89mysfwgn605d1y";
  };
  lib = import "${krops}/lib";
  pkgs = import "${krops}/pkgs" { };

  # todo: use niv
  source = { host }: lib.evalSource [{
    nixpkgs.git = {
      clean.exclude = [ "/.version-suffix" ];
      ref = "a7e559a5504572008567383c3dc8e142fa7a8633";
      #ref = "84917aa00bf23c88e5874c683abe05edb0ba4078";
      url = https://github.com/NixOS/nixpkgs;
    };
    nixos-config.file = toString ./configuration.worker.nix;
    # todo: find a better way to do this string interpolation
    "hardware-configuration.nix".file = toString ./. + "/hosts/${host}/hardware-configuration.nix";
  }];

  w1 = pkgs.krops.writeDeploy "deploy-w1" {
    source = source { host = "w1"; };
    target = "root@w1.dmz.509ely.com";
  };

  w2 = pkgs.krops.writeDeploy "deploy-w2" {
    source = source { host = "w2"; };
    target = "root@w2.dmz.509ely.com";
  };

  w3 = pkgs.krops.writeDeploy "deploy-w3" {
    source = source { host = "w3"; };
    target = "root@w3.dmz.509ely.com";
  };
in
{
  all = pkgs.writeScript "deploy-all-servers"
    (lib.concatStringsSep "\n" [ w1 w2 w3 ]);
}
