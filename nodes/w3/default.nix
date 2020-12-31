{ ... }:
{
  imports = [
    ./../../modules/worker-configuration.nix
    ./../../modules/keepalived.nix
    ./../../modules/k3s.nix
  ];

  networking.hostName = "w3";
}
