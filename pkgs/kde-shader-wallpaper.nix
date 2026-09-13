{
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  kdePackages,
  qt6,
  glslang,
  pipewire,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kde-shader-wallpaper";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "y4my4my4m";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-aHX0mxBgO0jh8la1L98y/LttcShGn8Q79c6Qfb0LPSU=";
  };

  cmakeBuildType = "Release";
  dontWrapQtApps = true;
  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    kdePackages.extra-cmake-modules
    kdePackages.kconfig
    kdePackages.ki18n
    kdePackages.kpackage
    kdePackages.libplasma
    glslang
    pipewire
  ];

  fixupPhase = ''
    rm -r $out/libexec
  '';

  meta = {
    description = "KDE / Plasma - Shader Wallpaper plugin";
    homepage = "https://github.com/y4my4my4m/kde-shader-wallpaper";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
