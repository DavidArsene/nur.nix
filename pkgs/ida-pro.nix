{
  python313,
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
  fetchPypi,
  fetchurl,

  lib,
  ...
}:
let
  pythonForIDA = python313.withPackages (
    ps:
    let
      fetchPythonWheel =
        pname: version: hash:
        ps.buildPythonPackage rec {
          inherit pname version;
          format = "wheel";

          src = fetchPypi {
            dist = "py3";
            python = "py3";
            format = "wheel";
            inherit pname version hash;
          };

          pythonRemoveDeps = [ "ida-hcli" ];
        };

    in
    with ps;
    [
      rpyc
      unicorn
      # pybinwalk

      # (fetchPythonWheel "ida_hcli" "0.17.5" "sha256-ZxCAY5mr5QT5LZgN5+NsNFGyIiQ5HT8JUHz9W62XwXc=")
      # (fetchPythonWheel "ida_settings" "3.3.0" "sha256-6WGDhT0VoJLRFinE6UsJYkxBf6eX2srA9Kt8na18d9g=")

    ]
  );
in
stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.3sp1";

  src = requireFile rec {
    message = ''
      Legally download the installer: ${name}

      Then add it to the nix store:
      $ nix store prefetch-file file://...

      The hash should match this:
      ${hash}
    '';
    name = "ida-pro_93_x64linux.run";
    hash = "sha256-CVv1EUt2RSNqHuQ7ZfZKyn2jM368bn+XmQd9tvWM0wc=";
  };

  hcli-bin =
    let
      rev = "0.17.5";
    in
    fetchurl {
      url = "https://github.com/HexRaysSA/ida-hcli/releases/download/v${rev}/hcli-linux-x86_64-${rev}";
      hash = "sha256-jPO8s9nOFk5iGgjuk0xqNiph2wYQ7jnetv6NA5e0yZ0=";
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
    # 0x5C just so happens to represent "\", and guess what
    # it's converted first then parsed in the regex
    # before='\xED\xFD\x42\x5C'

    before='\xED\xFD\x42\\'
    after='\xED\xFD\x42\xCB'

    for file in opt/libida{,32}.so; do
      echo "Patching $file"
      sed -i "s/$before/$after/g" $file
    done
    #! End Patch

    cp -r opt/* $IDADIR/

    # Link the exported libraries to the output.
    for lib in $IDADIR/*.so; do # $IDADIR/*.so.6
      ln -s $lib $out/lib/$(basename $lib)
    done

    # Manually patch libraries that dlopen stuff.
    patchelf --add-needed libpython3.13.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so
    patchelf --add-needed libsecret-1.so.0 $out/lib/libida.so

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Link the binaries to the output.
    for bb in ida; do
      wrapProgram $IDADIR/$bb \
        --prefix IDADIR : $IDADIR \
        --prefix PYTHONPATH : $IDADIR/idalib/python \
        --set LUMINA_TLS 0 # for custom Lumina servers

      ln -s $IDADIR/$bb $out/bin/$bb
    done

    cp ${hcli-bin} $IDADIR/hcli
    chmod +x $IDADIR/hcli
    wrapProgram $IDADIR/hcli --set HCLI_CURRENT_IDA_INSTALL_DIR $IDADIR
    ln -s $IDADIR/hcli $out/bin/hcli

    install -m 444 -D $IDADIR/appico.png $out/share/icons/hicolor/128x128/apps/ida.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    mainProgram = "ida";
    maintainers = with maintainers; [
      msanft
      yanmaani
    ];
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
