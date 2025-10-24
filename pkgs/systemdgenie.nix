{
  stdenv,
  lib,
  cmake,
  pkg-config,
  extra-cmake-modules,
  fetchFromGitLab,
  wrapQtAppsHook,
  qtbase,
  ktexteditor,
  kxmlgui,
}:
stdenv.mkDerivation {
  pname = "systemdgenie";
  version = "0.100.0";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    repo = "SystemdGenie";
    owner = "system";
    rev = "3d268bc";
    hash = "sha256-oqe9yv0KJ1uGYsUvIMdgVSw/j2wR1XGnOB5K3fc2XRI=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    extra-cmake-modules
    wrapQtAppsHook
    qtbase
  ];

  buildInputs = [
    ktexteditor
    kxmlgui
  ];

  meta = with lib; {
    description = "Systemd management utility";
    mainProgram = "systemdgenie";
    homepage = "https://kde.org";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
