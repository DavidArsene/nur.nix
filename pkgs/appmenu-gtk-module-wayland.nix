{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  pkg-config,
  libdbusmenu-gtk3,
  libsysprof-capture,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appmenu-gtk-module-wayland";
  version = "0-unstable-2026-07-25";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "guiodic";
    repo = "appmenu-gtk-module-wayland";
    rev = "38f7469dc06fd1a3a3e6d500d7cec2fa32b4e227";
    hash = "sha256-DJJ6ecetfqjMw2FxAapN2PNp1Prk1/XzGbdL/WyQ3Zo=";
  };

  buildInputs = [
    # gtk3
    libdbusmenu-gtk3
    libsysprof-capture
  ];

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
  ];

  meta = {
    description = "GTK global menu on Plasma Wayland";
    homepage = "https://github.com/guiodic/appmenu-gtk-module-wayland";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
  };
})
