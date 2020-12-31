{ pkgs, ... }:
{
  imports = [ ./common-k3s.nix ];

  environment.systemPackages = with pkgs; [ k3s ];

  services = {
    k3s = {
      enable = false;
      role = "server";
      serverAddr = "https://10.25.89.5:6443"; # todo: DRY
      extraFlags = "";
    };
  };
}
