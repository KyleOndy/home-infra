{ ... }:
{
  imports = [
    ./../../modules/worker-configuration.nix
    ./../../modules/worker-keepalived.nix
    ./../../modules/worker-k3s.nix
  ];

  networking.hostName = "w1";
}
