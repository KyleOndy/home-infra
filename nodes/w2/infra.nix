{ pkgs, ... }:
{
  services = {
    consul = {
      enable = true;
      extraConfig = {
        server = true;
        bootstrap_expect = 1;
        bind_addr = "10.25.89.22"; # todo: hardcode
      };
    };
    nomad = {
      enable = true;
      settings = {
        server = {
          enabled = true;
          bootstrap_expect = 1;
        };
        client = {
          enabled = true;
        };
      };
    };
    traefik = {
      enable = true;
      # todo: what is static, and what is dynamic?
      #dynamicConfigFile = ./traefik.toml;
      staticConfigFile = ./traefik.toml;
      # todo: dynamicConfigOptions = { };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
