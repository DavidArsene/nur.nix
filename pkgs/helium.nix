{
  appimageTools,
  fetchurl,
  lib,
  lang ? "en-US",
}:

appimageTools.wrapType2 rec {
  pname = "helium";
  version = "0.7.2.1";

  src = fetchurl {
    url = "${meta.homepage}/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "sha256-PwXgpmauBN6EXoZE6HnpgrisrO5a9VzQEDv3T2OsPnc=";
  };

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'

      cp -r ${contents}/usr/share/* $out/share/

      localeFiles="${contents}/opt/${pname}/locales/${lang}*"
      echo "Installing files for locale ${lang}:"
      ls $localeFiles

      install -d $out/share/lib/${pname}/locales
      cp $localeFiles $out/share/lib/${pname}/locales
    '';

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://github.com/imputnet/helium-linux";
    changelog = "${meta.homepage}/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = [
      "Ev357"
      "Prinky"
      "DavidArsene"
    ];
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
