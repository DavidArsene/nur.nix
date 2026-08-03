{ pkgs, ... }:
let
  pythopt = pkgs.python315.override {
    enableOptimizations = true;
    reproducibleBuild = false;

    withMinimalDeps = true;
    stripBytecode = false;

    self = pythopt;
  };
in
pythopt
