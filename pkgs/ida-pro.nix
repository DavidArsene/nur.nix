{
  python314,
  qt6,
  gtk3,
  libsecret,
  stdenv,
  makeWrapper,
  autoPatchelfHook,
  requireFile,
  libxcrypt-legacy,
  copyDesktopItems,
  makeDesktopItem,
  hcli,

  lib,
  ...
}:
let
  pythonForIDA = python314.withPackages (
    ps: with ps; [
      ida-hcli
      ida-settings

      rpyc
      unicorn
      # pybinwalk
    ]
  );
in

# cc needed for $NIX_CC/nix-support/dynamic-linker
stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.4.260714";

  src = requireFile rec {
    message = ''
      Legally download the installer: ${name}

      Then add it to the nix store:
      $ nix store prefetch-file file://...

      The hash should match this:
      ${hash}
    '';
    name = "ida-pro_94_x64linux.run";
    hash = "sha256-6rtkw8hJ04WHWVWDWenOvPF+KpG8xgUjUz34uERiqlQ=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "ida-pro";
      exec = "ida";
      comment = meta.description;
      icon = "ida";
      desktopName = "IDA Pro";
      genericName = "Interactive Disassembler";
      categories = [ "Development" ];
      startupWMClass = "IDA";
    })
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6WaylandCompositor.so.6"
    "libQt6WlShellIntegration.so.6"
  ];

  buildInputs = [
    libsecret
    libxcrypt-legacy
    gtk3
    pythonForIDA
  ]
  ++ qt6.qtbase.propagatedBuildInputs
  ++ qt6.qtwayland.propagatedBuildInputs;

  dontWrapQtApps = true;

  # We just get a runfile in $src, so no need to unpack it.
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/opt $out/share/icons/hicolor/128x128/apps

    IDADIR="$out/opt"
    # IDA doesn't always honor `--prefix`, so we need to hack and set $HOME here.
    HOME="$PWD/opt"

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --debuglevel 4 --prefix $HOME

    rm -v opt/cfg/pic*.cfg
    rm -v opt/?ninstall*
    rm -r opt/docs/

    #! Patch
    before='29f4481f796f9f66f2ff13cc4ab5b54f60845db603ba2c0bac8a9bc4b6cbdefc5c62bfc2f5ee850ac45ea97ad347e8b56dba5085af8c8aad9cc2ec626ca78a068006d658f68651da31a0a77c65a70ed73a40d53b08edd403c095aa0bcffa52f313ebcacaaa2ce5024a4e2b9aa70fc6092f38ae094d71e43f7690b5ddd3e9e4f7'
    after='a107b71c8a08ba5350934f7cf6e81be3a24dc2e35f7200d80cbd70b37ed6811dd2146d3cb7e20ad19b2544c0ef14c5c66ffbbdf226ec3f3d544c04385303ca4a7179299340022f5d50948bcf8a60307e2c196329e51a5296dc419e40fef3ef7c6f015a09ebd979e79615338985643e666c14897f9f597e11f44341f496d56861'

    for file in opt/libida{,32}.so; do
      echo "Patching $file"
      ${lib.getExe pythonForIDA} -c "import sys; data = open('$file', 'rb').read(); open('$file', 'wb').write(data.replace(bytes.fromhex('$before'), bytes.fromhex('$after')))"
    done
    #! End Patch

    cp -r opt/* $IDADIR/

    ${lib.getExe pythonForIDA} -m compileall -s $IDADIR $IDADIR

    # Link the exported libraries to the output.
    for lib in $IDADIR/*.so; do # $IDADIR/*.so.6
      ln -s $lib $out/lib/$(basename $lib)
    done

    # Manually patch libraries that dlopen stuff.
    patchelf --add-needed libpython3.14.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so
    patchelf --add-needed libsecret-1.so.0 $out/lib/libida.so

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Link the binaries to the output.
    for bb in ida; do
      makeWrapper $IDADIR/$bb $out/bin/$bb \
        --prefix PATH : ${lib.makeBinPath [ pythonForIDA ]} \
        --set IDADIR $IDADIR \
        --set LUMINA_TLS 0 # for custom Lumina servers
        # --set PYTHONVERBOSE 1
    done

    makeWrapper ${lib.getExe hcli} $out/bin/hcli \
      --set HCLI_CURRENT_IDA_INSTALL_DIR $IDADIR \
      --set HCLI_CURRENT_IDA_PYTHON_EXE ${lib.getExe pythonForIDA}

    install -m 444 -D $IDADIR/appico.png $out/share/icons/hicolor/128x128/apps/ida.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    mainProgram = "ida";
    maintainers = with maintainers; [
      msanft
      yanmaani
    ];
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
