{
  fetchurl,
  fetchFromGithub,

  jadx,
  librsvg,
  copyDesktopItems,

  jetbrains,
  jdk ? jetbrains.jdk-no-jcef,

  jre_minimal,
  # TODO: untested
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
  quark-engine,
}:
jadx.overrideAttrs rec {
  version = "1.5.5";

  src = fetchurl {
    url = "https://github.com/skylot/jadx/releases/download/v${version}/jadx-${version}.zip";
    hash = "sha256-OKV2bTyBcMQVZrSxPqDt4kMOMAhCGvSScjXCiAI01Ro=";
  };

  logos = fetchFromGithub {
    owner = "skylot";
    repo = "jadx";
    rev = version;
    hash = "sha256-OKV2bTyBcMQVZrSxPqDt4kMOMAhCGvSScjXCiAI01Ro=";

    rootDir = "jadx-gui/src/main/resources/logos";
  };

  patches = [ ];

  nativeBuildInputs = [
    librsvg
    copyDesktopItems
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp -R lib $out

    for prog in jadx jadx-gui; do
      cp bin/$prog $out/bin

      substituteInPlace $out/bin/$prog \
        --replace-fail '$JAVA_HOME' "${jdk.home}"
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
}
