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
