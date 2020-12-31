{ config, ... }:
{
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      masterNode = {
        interface = "eth0";
        state = "MASTER";
        virtualIps = [{ addr = "10.25.89.10"; }];
        virtualRouterId = 10;
      };
    };
  };
}
