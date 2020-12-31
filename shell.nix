{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    pkgs.detect-secrets

    # for markdown-lint (pre-commit check)
    pkgs.ruby
  ];
}
