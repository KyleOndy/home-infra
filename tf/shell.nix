{ pkgs ? import <nixpkgs> { } }:

with pkgs;

stdenv.mkDerivation {
  name = "home_infra";

  buildInputs = [
    terraform
  ];

  shellHook = ''
    export AWS_ACCESS_KEY_ID="AKIAW4WHQVVU5JE3CCMT"
    export AWS_SECRET_ACCESS_KEY="$(pass show aws.amazon.com/ondy/keys/AKIAW4WHQVVU5JE3CCMT)"
  '';
}
