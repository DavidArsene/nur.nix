{
  appimageTools,
  fetchurl,
  lib,
  lang ? "en-US",
}:

appimageTools.wrapType2 rec {
  pname = "helium";
  version = "0.10.0.1";

  src = fetchurl {
    url = "${meta.homepage}/releases/download/${version}/helium-${version}-x86_64.AppImage";
    hash = "";
  };

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit pname version src; };
    in
    ''
      install -m 444 -D ${contents}/${pname}.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/${pname}.desktop \
        --replace-warn 'Exec=AppRun' 'Exec=${meta.mainProgram}' \
        --replace-warn 'Exec=${pname}' 'Exec=${meta.mainProgram}'

      cp -r ${contents}/usr/share/* $out/share/

      localeFiles="${contents}/opt/${pname}/locales/${lang}*"
      echo "Installing files for locale '${lang}':"
      ls $localeFiles

      install -d $out/share/lib/${pname}/locales
      cp $localeFiles $out/share/lib/${pname}/locales
    '';

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://github.com/imputnet/helium-linux";
    changelog = "${meta.homepage}/releases/tag/${version}";
    license = lib.licenses.gpl3;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
