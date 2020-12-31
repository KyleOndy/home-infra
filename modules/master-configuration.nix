# This is a slimmed down version of the config that is generated with
# nixos-generate-config. I removed everything that I understood well
# enough to be sure it is not necessary for working on nixos via ssh.

{ config, pkgs, ... }:

{
  imports = [
    ./master-hardware-configuration.nix
    ./common-configuration.nix
  ];

  # Make it boot on the RP, taken from here: https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4
  boot = {
    loader = {
      grub.enable = false;
      raspberryPi.enable = true;
      raspberryPi.version = 4;
    };
    kernelPackages = pkgs.linuxPackages_rpi4; # Mainline doesn't work yet
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.03"; # Did you read the comment?

}
