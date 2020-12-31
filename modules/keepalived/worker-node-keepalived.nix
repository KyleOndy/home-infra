{ config, ... }:
{
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      workerNodes = {
        interface = "enp2s0";
        state = "MASTER";
        virtualIps = [{ addr = "10.25.89.20"; }];
        virtualRouterId = 20;
      };
    };
  };
}
