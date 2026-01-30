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

  #! Hopefully switching from excludes to includes won't cause problems later
  bundledOnlyPlugins ? {
    # "com.intellij" = "../lib";
    "com.intellij.modules.ultimate" = "ultimate-plugin";

    "ByteCodeViewer" = "java-byteCodeViewer";
    "org.jetbrains.debugger.streams" = "java-debugger-streams";
    "org.jetbrains.java.decompiler" = "java-decompiler";

    "com.android.tools.gradle.dcl" = "android-gradle-declarative-lang-ide";
    "org.jetbrains.idea.gradle.dsl" = "android-gradle-dsl";
    "com.intellij.compose" = "compose-ide-plugin";

    "Git4Idea" = "vcs-git";
    # "com.intellij.aop" = "aopCommon";
    "com.intellij.diagram" = "uml";
    "intellij.grid.plugin" = "grid-plugin";
    "com.intellij.platform.images" = "platform-images";
    "com.intellij.stats.completion" = "statsCollector";
    "com.jetbrains.performancePlugin" = "performanceTesting";
    "com.jetbrains.performancePlugin.async" = "performanceTesting-async";
    "org.intellij.groovy.live.templates" = "groovy-live-templates";
    "org.intellij.plugins.markdown" = "markdown";

    # "com.intellij.ja" = "localization-ja";
    # "com.intellij.ko" = "localization-ko";
    # "com.intellij.zh" = "localization-zh";

    # "com.intellij.jpa.jpb.model" = "JPA Model";
    # "com.intellij.jsp" = "javaee-jsp-base-impl";
    # "com.intellij.persistence" = "javaee-persistence-impl";
    # "com.intellij.microservices.jvm" = "microservices-jvm";
    # "org.jetbrains.idea.eclipse" = "eclipse";
    "org.jetbrains.plugins.textmate" = "textmate-plugin";

    # "com.jetbrains.codeWithMe" = "cwm-plugin";
    "com.jetbrains.gateway" = "gateway-plugin";
    # "com.jetbrains.station" = "station-plugin";
    "intellij.platform.ijent.impl" = "platform-ijent-impl";

    #? <essential-plugin>s in IdeaApplicationInfo.xml,
    #? IDE will artificially not run without them.
    "com.intellij.java" = "java";
    "com.intellij.java.ide" = "java-ide-customization";
    "com.intellij.modules.json" = "json";

    #! Set registry kotlin.k2.only.bundled.compiler.plugins.enabled	to false
    # "org.jetbrains.kotlin" = "Kotlin"; # ? seems ok
    "org.intellij.groovy" = "Groovy";
    "com.intellij.properties" = "properties"; # ! Needed by Groovy
  },

  topLevelDirs ? [
    "bin"
    "lib"
    "modules"
    "product-info.json"
  ],

  withCppDeps ? true,
  clang,
  clazy,
  # lldb,
  # gdb,

  hasGdbWithBundledPython ? withCppDeps,
  python312,
  openssl,
  libxcrypt-legacy,

  iUsedTheWrapperCorrectly ? false,
}:

assert iUsedTheWrapperCorrectly;
stdenv.mkDerivation rec {

  #! NOTE: Cannot be used without the wrapper!
  pname = "idea-unwrapped";
  version = "2026.1-eap5";
  passthru.buildNumber = "261.21525.39";

  dontUnpack = true;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/idea-${passthru.buildNumber}.tar.gz";
    hash = "sha256-UVyg0zm3xkEJ3lU1eOT6HtyFqA0owfNmkS/jlKRA+O4=";
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
  ++ lib.optionals hasGdbWithBundledPython [
    python312
    openssl
    libxcrypt-legacy
  ];

  autoPatchelfIgnoreMissingDeps = [ "libX11.so.6" ];

  installPhase =
    let
      bashJoin = lib.concatStringsSep ",";
    in
    ''
      mkdir -p $out
      cd $out || exit 1

      tar -xzf $src --strip-components=1 \
        --wildcards --no-wildcards-match-slash \
        \
        'idea-IU-*'/{${bashJoin topLevelDirs}} \
        \
        'idea-IU-*'/plugins/{${bashJoin (lib.attrValues bundledOnlyPlugins)}}

      # TODO: Recreate removed sh's (format inspect ltedit)
      rm -vf bin/{idea,*.sh}
      # JetBrains Client is part of Code With Me / Remote Development
      # rm -vf bin/{jetbrains_client*,remote-dev-server*}

      ln -s ${libdbusmenu}/lib/libdbusmenu-glib.so bin/libdbm.so
      ln -sf ${lib.getExe fsnotifier} bin/fsnotifier
    ''
    + lib.optionalString withCppDeps ''
      mkdir -p bin/clang/linux/x64/bin
      ln -s ${clang}/bin/{clang,clangd,clang-format,clang-tidy} bin/clang/linux/x64/bin/
      ln -s ${clazy}/bin/clazy bin/clang/linux/x64/bin/clazy-standalone
    '';

  # TODO: needed or simply handled by autoPatchelfHook? i dont see why not
  #  postFixup = lib.optionalString withCppDeps ''
  #    ls -d \
  #      $out/*/bin/*/linux/*/lib/liblldb.so \
  #      $out/*/bin/*/linux/*/lib/python3.8/lib-dynload/* \
  #      $out/*/plugins/*/bin/*/linux/*/lib/liblldb.so \
  #      $out/*/plugins/*/bin/*/linux/*/lib/python3.8/lib-dynload/* |
  #    xargs patchelf \
  #      --replace-needed libssl.so.10 libssl.so \
  #      --replace-needed libssl.so.1.1 libssl.so \
  #      --replace-needed libcrypto.so.10 libcrypto.so \
  #      --replace-needed libcrypto.so.1.1 libcrypto.so \
  #      --replace-needed libcrypt.so.1 libcrypt.so
  #  '';
}

# plugins = callPackage ./plugins { } // {
#   __attrsFailEvaluation = true;
# };
