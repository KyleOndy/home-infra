{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ keepalived ];

  networking.firewall.extraCommands = "iptables -A INPUT -p vrrp -j ACCEPT";
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      default = {
        interface = "enp2s0";
        state = "MASTER";
        virtualIps = [{ addr = "10.25.89.5"; }];
        virtualRouterId = 1;
      };
    };
  };
}
