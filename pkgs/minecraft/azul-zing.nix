{
  autoPatchelfHook,
  fetchzip,
  lib,
  setJavaClassPath,
  stdenv,
  zlib,

  type ? "jre",
  arch ? "x64",
  distro_version ? [
    25
    12
    0
    0
  ],
  java_version ? [
    21
    0
    9
  ],
  distro_build_number ? "3",
}:

# Respectfully kanged from
# https://github.com/NixOS/nixpkgs/pull/256354

assert arch == "x64" || arch == "aarch64";
assert type == "jre" || type == "jdk";
# No JRE builds for ARM
assert arch == "aarch64" -> type == "jdk";

let
  listToVersion = lib.concatMapStringsSep "." toString;

  cdnRoot = "https://cdn.azul.com/zing-zvm";
  distro = listToVersion distro_version;
  java = type + listToVersion java_version;

  #? Final attributes
  url = "${cdnRoot}/ZVM${distro}/zing${distro}-${distro_build_number}-${java}-linux_${arch}.tar.gz";
  hash = "sha256-iJ03eNvqk0DDqrpf//CCjAz5nIceMgB6sZXpJjz0CLA=";
in

stdenv.mkDerivation (finalAttrs: {
  pname = "zing-jre";
  version = distro;

  src = fetchzip { inherit url hash; };

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];
  nativeBuildInputs = [ autoPatchelfHook ];
  propagatedBuildInputs = [ setJavaClassPath ];

  installPhase = ''
    # Illegal
    rm -r legal/

    # Only ones that depend on xorg and alsa
    # Not used by Minecraft so whatever
    rm lib/lib{awt_xawt,jawt,jsound,splashscreen}.so

    mkdir $out
    cp -r ./* $out/
  '';

  strictDeps = true;

  meta = {
    homepage = "https://www.azul.com/products/prime";
    changelog = "https://docs.azul.com/prime/release-notes";

    # ! CRITICAL: cannot download files without account or API token anymore
    broken = true;

    # TODO: Java 25 when?
    # https://api.azul.com/metadata/v1/docs/swagger
    # https://api.azul.com/metadata/v1/zing/packages?archive_type=tar.gz&java_version=21&latest=true&azul_com=true
    downloadPage = "https://www.azul.com/downloads/#prime";

    description = "High performance JVM implementation with low GC pause time";
    longDescription = ''Azul Zing, the supposedly "world's best" JVM, packaged specifically for Minecraft.'';
    maintainers = [ "DavidArsene" ];
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "java";
  };
})
