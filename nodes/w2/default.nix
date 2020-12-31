{ ... }:
{
  imports = [
    ./../../modules/worker-configuration.nix
    ./../../modules/keepalived/worker-node-keepalived.nix
    ./../../modules/agent-k3s.nix
  ];

  networking = {
    hostName = "w2";
    interfaces.enp2s0.ipv4 = {
      addresses = [{
        address = "10.25.89.22";
        prefixLength = 24;
      }];
    };
  };
}
