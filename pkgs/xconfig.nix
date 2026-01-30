{
  buildPackages,
  linux_testing,
  qt6,

  kernel ? linux_testing,
}:

buildPackages.stdenv.mkDerivation {
  inherit (kernel) src version;
  pname = "xconfig";

  depsBuildBuild = with buildPackages; [
    stdenv.cc
    bison
    flex
    pkg-config
    qt6.qtbase
    # qt6.wrapQtAppsHook
  ];

  dontWrapQtApps = true;

  # TODO: not needed?
  # postPatch = "patchShebangs scripts/";

  buildPhase = ''
    # set -x
    make xconfig || true
    # cd scripts/kconfig
    # make qconf
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp scripts/kconfig/qconf $out/bin/
  '';

  meta = {
    # FIXME: unfinished
    broken = true;
  };
}
