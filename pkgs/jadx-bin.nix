{
  fetchurl,
  fetchFromGitHub,

  jadx,
  stdenvNoCC,
  librsvg,
  copyDesktopItems,
  makeDesktopItem,
  unzip,

  jre_minimal,
  # TODO: untested
  # TODO https://docs.oracle.com/en/java/javase/17/docs/specs/man/jlink.html
  jre ? jre_minimal.override {
    modules = [
      "java.base"
      "java.desktop"
      "java.naming"
      "java.security"
      "java.sql"
      "java.xml"
      "jdk.crypto.ec"
      "jdk.crypto.cryptoki"
      "jdk.localedata"
      "jdk.net"
    ];
    # TODO: --include-locales
  },
}:
stdenvNoCC.mkDerivation rec {
  pname = "jadx-bin";
  inherit (jadx) version;

  src = fetchurl {
    url = "${meta.homepage}/releases/download/v${version}/jadx-${version}.zip";
    hash = "sha256-OKV2bTyBcMQVZrSxPqDt4kMOMAhCGvSScjXCiAI01Ro=";
  };

  logos = fetchFromGitHub {
    owner = "skylot";
    repo = "jadx";
    rev = "v" + version;
    hash = "sha256-MAkxJ/Q8+Oq2HVkXFtwqqj5JwPeyUjwDWREcNuRQX3U=";

    rootDir = "jadx-gui/src/main/resources/logos";
  };

  nativeBuildInputs = [
    librsvg
    copyDesktopItems
    unzip
  ];
  sourceRoot = "."; # squash "unpacker produced multiple directories" error

  desktopItems = [
    (makeDesktopItem {
      name = "jadx";
      desktopName = "JADX";
      exec = "jadx-gui";
      icon = "jadx";
      comment = meta.description;
      categories = [
        "Development"
        "Utility"
      ];
    })
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -R lib $out

    for prog in jadx jadx-gui; do
      cp bin/$prog $out/bin
      chmod +x $out/bin/$prog

      substituteInPlace $out/bin/$prog \
        --replace-fail '$JAVA_HOME' "${jre.home}"
    done

    for size in 16 32 48; do
      install -Dm444 \
        ${logos}/jadx-logo-"$size"px.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/jadx.png
    done
    for size in 64 128 256; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      rsvg-convert --width "$size" ${logos}/jadx-logo.svg > $out/share/icons/hicolor/"$size"x"$size"/apps/jadx.png
    done

  '';

  meta = {
    description = "Dex to Java decompiler";
    homepage = "https://github.com/skylot/jadx";
  };
}
