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
    shell_dir="${toString ./.}"
    export NIX_PATH="nixpkgs=$shell_dir/vendor/nixpkgs"
  '';
}
