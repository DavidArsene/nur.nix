{
  fetchpatch,
  fetchzip,
  runtimeShell,
  stdenvNoCC,

  fprintd,
  libfprint,
  ...
}:
let
  fpcbep = fetchzip {
    url = "https://download.lenovo.com/pccbbs/mobiles/r1slm02w.zip";
    hash = "sha256-/buXlp/WwL16dsdgrmNRxyudmdo9m1HWX0eeaARbI3Q=";
    stripRoot = false;
  };

  fpc-driver-base = "FPC_driver_linux_27.26.23.39/install_fpc";
  libfprint-base = "FPC_driver_linux_libfprint/install_libfprint";

  # No longer works since 396 now has merge conflicts
  libfprint-fpc = libfprint.overrideAttrs (attrs: {
    doInstallCheck = false;
    patches = [
      (fetchpatch {
        url = "https://gitlab.freedesktop.org/libfprint/libfprint/-/merge_requests/396.patch";
        hash = "sha256-+5B5TPrl0ZCuuLvKNsGtpiU0OiJO7+Q/iz1+/2U4Taw=";
      })
    ];

    postPatch = attrs.postPatch + ''
      substituteInPlace meson.build --replace \
        "find_library('fpcbep', required: true)" \
        "find_library('fpcbep', required: true, dirs: '$out/lib')"
    '';

    preConfigure = ''
      install -D -t "$out/lib" "${fpcbep}/${fpc-driver-base}/libfpcbep.so"
    '';

    postInstall = ''
      rules="lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
      install -Dm644 -t "$out/lib" "${fpcbep}/${libfprint-base}/$rules"

      substituteInPlace "$out/lib/udev/rules.d/70-libfprint-2.rules" --replace "/bin/sh" "${runtimeShell}"
    '';
  });

  libfprint-fpc-prebuilt = stdenvNoCC.mkDerivation {
    pname = "libfprint-fpc-prebuilt";
    version = "2.0.0";
    src = fpcbep;

    installPhase = ''
      runHook preInstall

      install -D -t "$out/lib" "${fpc-driver-base}/libfpcbep.so"
      install -D -t "$out/lib" "${libfprint-base}/usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0"

      ln -s "libfprint-2.so.2.0.0" "$out/lib/libfprint-2.so.2"
      ln -s "libfprint-2.so.2" "$out/lib/libfprint-2.so"

      rules="lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
      install -Dm644 -t "$out/lib" "${libfprint-base}/$rules"

      runHook postInstall
    '';
  };
in
{
  services.fprintd = {
    enable = true;

    package = fprintd.override { libfprint = libfprint-fpc-prebuilt; };
  };
  services.udev.packages = [ libfprint-fpc-prebuilt ];
}
