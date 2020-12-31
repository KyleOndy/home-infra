{ ... }:
{
  imports = [ ./common-k3s.nix ];

  services = {
    k3s = {
      enable = true;
      role = "agent";
      serverAddr = "https://10.25.89.5:6443"; # todo: DRY
      # todo: manaully replace when rebuilding masters. Found at
      #       `/var/lib/rancher/k3s/server/node-token`.
      # todo: roll this and keep it a secret
      token = "K1024949ecb7622d2aa4dc75d558fb393f01129de54d37f9c989568b1822892d740::server:211cc7d38165709e7bdfc192e33fe7f2";
    };
  };
}
