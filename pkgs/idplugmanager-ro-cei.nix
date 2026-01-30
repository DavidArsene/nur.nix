{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  dpkg,
  wrapGAppsHook3,

  pcsclite,
  libx11,
  gtk3,
  openssl,
  libjpeg8,
}:
stdenv.mkDerivation rec {
  pname = "idplugmanager-ro-cei";
  version = "4.5.0";

  src = fetchurl {
    url = "https://hub.mai.gov.ro/cei/info/descarca-middleware?versiune=${
      lib.replaceString "." "" version
    }linux";
    hash = "sha256-TQhEANzYBTX8v14rMZTplgOeyWGZJBVzsdY697/rBIQ=";
    name = "idplug-classic-${version}-noble-romania.deb";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
    dpkg # hook
  ];

  buildInputs = [
    pcsclite
    openssl
    libjpeg8
    gtk3
    libx11
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    shopt -s extglob
    rm -rf usr/share/idplugclassic/locales/!(ro_RO)

    mkdir -p $out/{.usr,bin,share}
    mv usr/* $out/.usr/

    mv $out/.usr/share/applications $out/share/
    ln -sv $out/.usr/bin/idplugclassic/identitymanager $out/bin/
    ln -sv $out/.usr/lib/idplugclassic $out/lib
  '';

  # To enable relative path lookups for .usr/
  preFixup = ''
    gappsWrapperArgs+=(--chdir $out)
  '';

  postFixup = ''
    cd $out

    substituteInPlace share/applications/idplugmanager.desktop \
      --replace-fail Exec=/usr/bin/idplugclassic/ Exec="$out/bin/" \
      --replace-fail Icon=/usr Icon="$out/.usr"

    # Replace UTF-32LE encoded "/usr/" with ".usr/"
    function utf32le() {
      echo -n "$1" | sed -E 's|(.)|\1\\x00\\x00\\x00|g'
    }

    _USR=$(utf32le "usr/")
    for file in .usr/{bin,lib}/idplugclassic/*; do
      sed -i \
        -e 's|/usr/|.usr/|g' \
        -e "s|$( utf32le / )$_USR|$( utf32le . )$_USR|g" \
        $file && echo "Unhardcoded $file"
    done
  '';

  meta = {
    description = "Romanian eID card driver and companion";
    homepage = "https://hub.mai.gov.ro/aplicatie-cei";

    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "identitymanager";
  };
}
