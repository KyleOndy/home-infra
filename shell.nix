{}:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  #nixops = import "${sources.nixops.outPath}/shell.nix";
in
pkgs.mkShell {

  buildInputs = [
    # sources.nixops
    pkgs.nixos-generators

    # pre-commit
    # https://pre-commit.com/
    pkgs.pre-commit
    pkgs.detect-secrets
    pkgs.shfmt
    pkgs.ruby
  ];

  shellHook = ''
    export NIX_PATH=nixpkgs=${pkgs.path}
  '';
}
