{ ... }:
{
  imports = [
    ./../../modules/rpi4-configuration.nix
    ./../../modules/keepalived/master-node-keepalived.nix
    ./../../modules/keepalived/k3s-server-keepalived.nix
    ./../../modules/server-k3s.nix
  ];

  networking = {
    hostName = "m2";
    interfaces.eth0.ipv4 = {
      addresses = [{
        address = "10.25.89.12";
        prefixLength = 24;
      }];
    };
  };
}
