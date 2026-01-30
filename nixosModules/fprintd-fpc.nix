{ self, pkgs }:
let
  libfprint-fpc = self.packages.libfprint-fpc;
in
{
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override { libfprint = libfprint-fpc; };
  };
  services.udev.packages = [ libfprint-fpc ];
}
