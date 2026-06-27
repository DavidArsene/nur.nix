{ fetchFromGitHub, lenovo-legion, ... }:

lenovo-legion.overrideAttrs {
  version = "0.0.21-unstable-2026-05-11";
  # pyproject = true;

  src = fetchFromGitHub {
    owner = "johnfanv2";
    repo = "LenovoLegionLinux";
    rev = "7b6c0c117663c4e8c08db78f07609d5fc74e2e2b";
    hash = "sha256-3rzX3Qmc6Xbu0dVbLKzp8npTFOBdyZSrV84ev2yoXN8=";
  };
}

/*
  pkgs.linuxPackages_latest.extend (final: prev: {

    lenovo-legion-module = prev.lenovo-legion-module.overrideAttrs {

      inherit (self.packages.lll) src;

    };

  });
*/
