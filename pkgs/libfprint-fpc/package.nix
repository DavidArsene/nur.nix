{
  autoPatchelfHook,
  fetchzip,
  stdenvNoCC,

  pkgs,
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

  libfprint-fpc = libfprint.overrideAttrs (attrs: {
    pname = "libfprint-fpc"; # 10a5:9800

    doCheck = false;
    # not working
    # doInstallCheck = false;

    patches = [ ./396.patch ];

    postPatch = attrs.postPatch + ''
      substituteInPlace meson.build --replace \
        "find_library('fpcbep', required: true)" \
        "find_library('fpcbep', required: true, dirs: '$out/lib')"
    '';

    preConfigure = ''
      install -D -t "$out/lib" "${fpcbep}/${fpc-driver-base}/libfpcbep.so"
    '';

    postInstall = ''
      rudevle="lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
      cp "${fpcbep}/${libfprint-base}/$rudevle" $out/lib/udev/rules.d/
    '';
  });

  #! Earlier attempt to use the provided libfprint-2.so as well
  #! > Run-time dependency libfprint-2 found: NO (tried pkgconfig)
  #! Kept just in case

  libfprint-fpc-prebuilt = stdenvNoCC.mkDerivation {
    pname = "libfprint-fpc";
    version = "2.0.0";
    src = fpcbep;

    buildInputs = with pkgs; [
      glib
      gusb
      pixman
      nss
      libgudev
    ];
    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
      install -D -t "$out/lib" "${fpc-driver-base}/libfpcbep.so"
      install -D -t "$out/lib" "${libfprint-base}/usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0"

      ln -s "libfprint-2.so.2.0.0" "$out/lib/libfprint-2.so.2"
      ln -s "libfprint-2.so.2" "$out/lib/libfprint-2.so"

      rules="lib/udev/rules.d/60-libfprint-2-device-fpc.rules"
      install -Dm644 -t "$out/lib" "${libfprint-base}/$rules"
    '';
  };
in
libfprint-fpc
