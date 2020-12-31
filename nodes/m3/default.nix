{ ... }:
{
  imports = [
    ./../../modules/master-configuration.nix
    ./../../modules/master-keepalived.nix
    ./../../modules/master-k3s.nix
  ];

  networking.hostName = "m3";
}
