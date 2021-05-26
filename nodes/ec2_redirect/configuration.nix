### https://nixos.org/channels/nixos-unstable nixos

# TODO:
#   - setup SWAP
{ config, pkgs, modulesPath, ... }:
{
  # this was coppied from spinning up a copy of this AMI with no configuration.
  # I assume its possbile for this to change at some point and break things.
  # I'll need to keep an eye on it.
  imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;
  ec2.efi = true;


  # My config
  environment.systemPackages = with pkgs; [
    glances
    htop
    lsof
    neovim
    nginx
    rsync
    bat
  ];
  services.nginx = {
    enable = true;

    # Use recommended settings
    #recommendedGzipSettings = true;
    #recommendedOptimisation = true;
    # this setting sets the host header to 'kyleondy.com`, which fails becuse I
    # don't have the cert for that site in the homelab.
    #recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."kyleondy.com" = {
      #extraConfig = "rewrite ^([^.]*[^/])$ $1/ permanent;";
      forceSSL = true;
      enableACME = true;
      locations."/".return = "301 https://www.kyleondy.com\$request_uri";
      #locations."/" = {
      #  proxyPass = "https://kyleondy-web.apps.509ely.com";
      #  # required when the target is also TLS server with multiple hosts
      #  extraConfig = ''
      #    proxy_set_header X-Real-IP $remote_addr;
      #    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #    proxy_ssl_server_name on;
      #    '';
      #};
    };
  };
  security.acme = {
    acceptTerms = true;
    email = "kyle@ondy.org";
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
