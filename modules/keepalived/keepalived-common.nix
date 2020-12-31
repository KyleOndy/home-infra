{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ keepalived ];
  networking.firewall.extraCommands = "iptables -A INPUT -p vrrp -j ACCEPT";
}
