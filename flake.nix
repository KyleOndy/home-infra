{
  description = "Deploy a full system with hello service as a separate profile";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs }: {
    nixosConfigurations.m1 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./nodes/m1 ];
    };
    nixosConfigurations.m2 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./nodes/m2 ];
    };
    nixosConfigurations.m3 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [ ./nodes/m3 ];
    };
    nixosConfigurations.w1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nodes/w1 ];
    };
    nixosConfigurations.w2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nodes/w2 ];
    };
    nixosConfigurations.w3 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./nodes/w3 ];
    };

    # This is the application we actually want to run
    # defaultPackage.x86_64-linux = import ./hello.nix nixpkgs;

    deploy.nodes.m1 = {
      hostname = "m1.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          #sshUser = "root";
          sshUser = "kyle";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.m1;
        };
      };
    };
    deploy.nodes.m2 = {
      hostname = "m2.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          #sshUser = "root";
          sshUser = "kyle";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.m2;
        };
      };
    };
    deploy.nodes.m3 = {
      hostname = "m3.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          #sshUser = "root";
          sshUser = "kyle";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.m3;
        };
      };
    };
    deploy.nodes.w1 = {
      hostname = "w1.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          sshUser = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.w1;
        };
      };
    };
    deploy.nodes.w2 = {
      hostname = "w2.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          sshUser = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.w2;
        };
      };
    };
    deploy.nodes.w3 = {
      hostname = "w3.dmz.509ely.com";
      fastConnection = true;
      profiles = {
        system = {
          sshUser = "root";
          path =
            deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.w3;
        };
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
