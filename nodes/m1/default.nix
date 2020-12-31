{ ... }:
{
  imports = [
    ./../../modules/rpi4-configuration.nix
    ./../../modules/keepalived/master-node-keepalived.nix
    ./../../modules/keepalived/k3s-server-keepalived.nix
    ./../../modules/server-k3s.nix
  ];

  networking = {
    hostName = "m1";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "10.25.89.11";
        prefixLength = 24;
      }];
    };
  };
}
