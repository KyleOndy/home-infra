{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./infra.nix
    ../../modules/concourse.nix
  ];

  nixpkgs.overlays = [ (import ../../pkgs) ];

  environment.systemPackages = with pkgs; [
    concourse
    glances
    neovim
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  users.users.root.password = "nixos";
  system.stateVersion = "21.05";
}
