{ pkgs, ... }:
{
  imports = [
    ./../../modules/rpi4-configuration.nix
    ./../../modules/keepalived/master-node-keepalived.nix
    #./../../modules/server-k3s.nix
  ];

  networking = {
    hostName = "m3";
    interfaces.eth0.ipv4 = {
      addresses = [{
        address = "10.25.89.13";
        prefixLength = 24;
      }];
    };
  };

  # leaving this inline until breaking it out into its own file(s) is worth the
  # cognitive overhead of not having it right here.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    enableTCPIP = true;
  };
}
