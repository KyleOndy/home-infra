{ config, ... }:
{
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      k3s = {
        interface = "eth0";
        state = "MASTER";
        virtualIps = [{ addr = "10.25.89.9"; }];
        virtualRouterId = 9;
      };
    };
  };
}
