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
      #ref = "34c7eb7545d155cc5b6f499b23a7cb1c96ab4d59"; # 19.03
      #ref = "75f4ba05c63be3f147bcc2f7bd4ba1f029cedcb1"; # 19.09
      #ref = "929768261a3ede470eafb58d5b819e1a848aa8bf"; # 20.03
      #ref = "ca119749d86f484066fae7680af8a44ea1f11ca8"; # 20.09
      ref = "84917aa00bf23c88e5874c683abe05edb0ba4078"; # unstable
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
