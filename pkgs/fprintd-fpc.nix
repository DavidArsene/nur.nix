{
  autoPatchelfHook,
  fetchzip,
  stdenvNoCC,

  fprintd,

  glib,
  gusb,
  pixman,
  nss,
  libgudev,
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

  libfprint-fpc-prebuilt = stdenvNoCC.mkDerivation {
    pname = "libfprint-fpc";
    version = "2.0.0";
    src = fpcbep;

    buildInputs = [
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

      cp -r "${libfprint-base}/lib/udev" "$out/lib"

      mkdir -p "$out/lib/pkgconfig"

      cat > "$out/lib/pkgconfig/libfprint-2.pc" <<'EOF'prefix=${pcfiledir}/..
            exec_prefix=${prefix}libdir=${prefix}/lib
            includedir=${prefix}/include

            Name: libfprint-2
            Description: libfprint 2 (FPC prebuilt)
            Version: 2.0.0
            Libs: -L${libdir} -lfprint-2
            Cflags: -I${includedir}EOF
    '';
  };

  fprintd-fpc = (fprintd.override { libfprint = libfprint-fpc-prebuilt; }).overrideAttrs {
    pname = "fprintd-fpc";
    doInstallCheck = false;
    passthru.udev = libfprint-fpc-prebuilt;
  };
in
fprintd-fpc
