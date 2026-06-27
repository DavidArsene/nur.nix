{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,

  fontconfig,
  libGL,
  lttng-ust_2_12,

  libdbusmenu,
  fsnotifier,

  topLevelDirs ? [
    "bin"
    "lib"
    "modules"
    "product-info.json"
  ],

  withCidrCppDeps ? false,
  clang,
  clazy,
  ninja,

  withCidrDebuggers ? false,
  lldb,
  gdb,

  hasGdbWithBundledPython ? withCidrDebuggers,
  python312,
  openssl,
  libxcrypt-legacy,

  iUsedTheWrapperCorrectly ? false,
}:

#! ---------------------------------------------------------------------
#! Set registry kotlin.k2.only.bundled.compiler.plugins.enabled	to false
#! ---------------------------------------------------------------------

assert iUsedTheWrapperCorrectly;
stdenv.mkDerivation rec {

  #! NOTE: Cannot be used without the wrapper!
  pname = "idea-unwrapped";
  version = "262.7132.23";

  dontUnpack = true;
  src = fetchurl {
    # version for releases, buildNumber for EAPs
    url = "https://download.jetbrains.com/idea/idea-${version}.tar.gz";
    hash = "sha256-eljThvKi5ajNfkWRZXtP5ZmurCLZYMesz1+SeEZQe/s=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # from buildIdea
  buildInputs = [
    stdenv.cc.cc.lib

    # > skiko renderer
    fontconfig
    libGL

    #? Used for storing and retrieving passwords.
    lttng-ust_2_12
  ]
  ++ lib.optionals withCidrDebuggers [
    lldb
    gdb
  ]
  ++ lib.optionals hasGdbWithBundledPython [
    python312
    openssl
    libxcrypt-legacy
  ];

  autoPatchelfIgnoreMissingDeps = [ "libX11.so.6" ];

  installPhase = ''
    mkdir -p $out
    cd $out || exit 1

    tar -xzf $src --strip-components=1 \
      --wildcards --no-wildcards-match-slash \
      'idea-IU-*'/{${lib.concatStringsSep "," topLevelDirs}}
    # 'idea-IU-*'/plugins/{...}

    #mkdir -p plugins
    #
    #for pluginSet in ''${lib.concatStringsSep " " extraPluginPackages}; do
    #  [[ -d "$pluginSet/plugins" ]] || continue
    #
    #  for pluginDir in "$pluginSet"/plugins/*; do
    #    [[ -e "$pluginDir" ]] || continue
    #    pluginName="$(basename "$pluginDir")"
    #    [[ -e "plugins/$pluginName" ]] && continue
    #    ln -s "$pluginDir" "plugins/$pluginName"
    #  done
    #done

    cd bin || exit 1
    # TODO: Recreate removed sh's (format inspect ltedit)
    rm -vf idea *.sh
    # JetBrains Client is part of Code With Me / Remote Development
    # rm -vf jetbrains_client* remote-dev-server*

    ln -s ${libdbusmenu}/lib/libdbusmenu-glib.so libdbm.so
    ln -sf ${lib.getExe fsnotifier} fsnotifier
  ''
  + lib.optionalString withCidrCppDeps ''
    mkdir -p {clang,ninja}/linux/x64/bin
    ln -s ${clang}/bin/{clang,clangd,clang-format,clang-tidy} clang/linux/x64/bin/
    ln -s ${clazy}/bin/clazy clang/linux/x64/bin/clazy-standalone
    ln -s ${ninja}/bin/ninja ninja/linux/x64/bin/

    # TODO:
    # - clang/linux/x64/{bin,include,lib}
    # - cmake/linux/x64/{bin,doc,share}

  ''
  + lib.optionalString withCidrDebuggers ''
    mkdir -p {lldb,gdb}/linux/x64/bin
    # - gdb/linux/x64/{bin,lib,share}
    # - lldb/linux/x64/{bin,lib,share}
    exit 1 # TODO
  '';

  # TODO: needed or already handled by autoPatchelfHook? i dont see why not
  #  postFixup = lib.optionalString withCidrCppDeps ''
  #    ls -d \
  #      $out/*/bin/*/linux/*/lib/liblldb.so \
  #      $out/*/bin/*/linux/*/lib/python3.*/lib-dynload/* \
  #      $out/*/plugins/*/bin/*/linux/*/lib/liblldb.so \
  #      $out/*/plugins/*/bin/*/linux/*/lib/python3.*/lib-dynload/* |
  #    xargs patchelf \
  #      --replace-needed libssl.so.10 libssl.so \
  #      --replace-needed libssl.so.1.1 libssl.so \
  #      --replace-needed libcrypto.so.10 libcrypto.so \
  #      --replace-needed libcrypto.so.1.1 libcrypto.so \
  #      --replace-needed libcrypt.so.1 libcrypt.so
  #  '';
}
