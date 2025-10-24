{
  autoPatchelfHook,
  fetchzip,
  lib,
  setJavaClassPath,
  stdenv,
  zlib,
}:
# Respectfully kanged from
# https://github.com/NixOS/nixpkgs/pull/256354
let
  dist = rec {

    version = "25.09.0.0";
    jreVersion = "21.0.8";
    unk = "3";
    url = "https://cdn.azul.com/zing-zvm/ZVM${version}/zing${version}-${unk}-jre${jreVersion}-linux_x64.tar.gz";
    hash = "sha256-+wqtl3fzuQXikXhPxbQuWAwREvPgU+CFEG/KEQBzsMg=";

    # version = "25.07.0.0";
    # jreVersion = "21.0.7.0.101";
    # url = "https://cdn.azul.com/zing-zvm/ZVM${version}/zing${version}-2-jre${jreVersion}-linux_x64.tar.gz";
    # hash = "sha256-UJTTz7xasZx/1tsxCJeCZxHiG+/Naw2tapMXmXM0l0U=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zing";
  inherit (dist) version;

  src = fetchzip { inherit (dist) url hash; };

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];
  nativeBuildInputs = [ autoPatchelfHook ];
  propagatedBuildInputs = [ setJavaClassPath ];

  installPhase = ''
    runHook preInstall

    # Illegal
    rm -r legal/
    
    # Only ones that depend on xorg and alsa
    # Not used by Minecraft so whatever
    rm lib/lib{awt_xawt,jawt,jsound,splashscreen}.so

    mkdir $out
    mv ./* $out/

    runHook postInstall
  '';

  strictDeps = true;

  meta = with lib; {
    homepage = "https://www.azul.com/products/prime";
    changelog = "https://docs.azul.com/prime/release-notes";
    downloadPage = "https://api.azul.com/metadata/v1/zing/packages?include_fields=sha256_hash&archive_type=tar.gz&latest=true";
    description = "High performance JVM implementation with low GC pause time";
    longDescription = ''Azul Zing, the supposedly "world's best" JVM, packaged specifically for Minecraft.'';
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "java";
  };
})
