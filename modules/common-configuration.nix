{ config, pkgs, ... }:

{
  time.timeZone = "America/New_York";


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZq6q45h3OVj7Gs4afJKL7mSz/bG+KMG0wIOEH+wXmzDdJ0OX6DLeN7pua5RAB+YFbs7ljbc8AFu3lAzitQ2FNToJC1hnbLKU0PyoYNQpTukXqP1ptUQf5EsbTFmltBwwcR1Bb/nBjAIAgi+Z54hNFZiaTNFmSTmErZe35bikqS314Ej60xw2/5YSsTdqLOTKcPbOxj2kulznM0K/z/EDcTzGqc0Mcnf51NtzxlmB9NR4ppYLoi7x+rVWq04MbdAmZK70p5ndRobqYSWSKq+WDUAt2+CiTm6ItDowTLuo3zjHyYV1eCnB35DdakKVldIHrQyhmhbf5hJi6Ywx6XCzlFoNpkl/++RrJT2rf0XpGdlRoLQoKFvNRfnO4LI499SIfFb9Pwq7LhF1C1kTmshN/9S44d6VCCYXLE4uS8OPv7IXxUvFQZaIKCbomd2FzXxUwf4lg2gSlczysgDaVsMAUvlfDVgTFX8Xt1LFl3DqNtUiUpa9+Jnst/jCqqOBf3e8= kyle@alpha"
  ];

  environment.systemPackages = with pkgs; [
    fd
    git
    glances
    htop
    mosh
    neovim
    ripgrep
    rsync
    screen
    tmux
    watch
  ];

  nix = {
    package = pkgs.nixUnstable;
    gc.automatic = true;
    optimise.automatic = true;
    buildMachines = [
      {
        hostName = "w1";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "w2";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "w3";
        system = "x86_64-linux";
        maxJobs = 1;
        speedFactor = 1;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }
    ];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command
    '';
  };
}
