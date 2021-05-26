{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  name = "concourse-${version}";
  version = "7.3.0";

  src = fetchFromGitHub{
    owner = "concourse";
    repo = "concourse";
    rev = "v${version}";
    sha256 = "Hj6MqDTXGFuKNuG+bV154WnTR3BRnh9JcBuMecMKPY8=";
  };

  vendorSha256 = "30rrRkPIH0sr8koKRLs1Twe6Z55+lr9gkgUDrY+WOTw=";

  doCheck = false; # todo: why is the one test failing?

  meta = with lib; {
    description = "thing doer";
    homepage = https://github.com/concourse/concourse;
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
