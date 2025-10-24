{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,

  musl,
  # lldb,
  fontconfig,
  libGL,
  # xorg.libX11,

  libsecret,
  e2fsprogs,
  libnotify,
  udev,

  libdbusmenu,
  fsnotifier,

  jbr,

  removedPlugins ? [
    "" # join buddy
    # "android-gradle-declarative-lang-ide"
    # "android-gradle-dsl"
    "angular"
    "aopCommon"
    "clouds-docker-gateway"
    "clouds-docker-impl"
    "clouds-kubernetes"
    # "completionMlRanking"
    "compose-ide-plugin"
    # "configurationScript"
    # "copyright"
    # "cron"
    "css-impl" # TODO::
    "cwm-plugin"
    "DatabaseTools"
    # "dev"
    "eclipse"
    # "editorconfig-plugin"
    "featuresTrainer"
    "flyway"
    "freemarker"
    "fullLine"
    "gateway-plugin"
    # "gradle"
    # "gradle-java"
    "grazie"
    # "grid-plugin"
    # "Groovy"
    "hibernate"
    "html-tools"
    # "indexing-shared"
    # "indexing-shared-ultimate-plugin-bundled"
    # "java"
    # "java-byteCodeViewer"
    "java-coverage"
    # "java-debugger-streams"
    # "java-decompiler"
    # "java-dsm"
    # "java-i18n" TODO:
    # "java-ide-customization"
    "JavaEE"
    "javaee-app-servers-impl"
    "javaee-appServers-jboss"
    "javaee-appServers-tomcat"
    "javaee-beanValidation"
    "javaee-cdi"
    "javaee-el-core"
    "javaee-extensions"
    "javaee-jakarta-data"
    "javaee-jax-rs"
    "javaee-jsp-base-impl"
    "javaee-persistence-impl"
    "javaee-reverseEngineering"
    "javaee-web-impl"
    "javaFX"
    "javascript-debugger"
    "javascript-intentions"
    "javascript-plugin" # TODO:
    "JPA"
    "JPA Model"
    # "json"
    # "jsonpath"
    "junit"
    "jupyter-plugin"
    "karma"
    "keymap-eclipse"
    "keymap-netbeans"
    "keymap-visualStudio"
    # "Kotlin"
    "kotlin-jupyter-plugin"
    # "ktor"
    "less"
    "liquibase"
    "localization-ja"
    "localization-ko"
    "localization-zh"
    "lombok"
    # "markdown"
    # "marketplaceMl"
    # "maven"
    "mcpserver"
    "micronaut"
    "microservices-jvm"
    "microservices-ui"
    "nextjs"
    "nodeJS"
    "nodeJS-remoteInterpreter"
    "notebooks-plugin"
    # "openRewrite"
    # "packageChecker"
    # "performanceTesting"
    # "performanceTesting-async"
    # "platform-ijent-impl" TODO:
    # "platform-images"
    # "platform-langInjection"
    "postcss"
    "prettierJS"
    # "profiler-lineProfiler"
    # "properties"
    # "protoeditor"
    "qodana"
    "quarkus"
    "react"
    "reactivestreams-core"
    "remote-dev-server"
    # "remoteRun"
    # "repository-search"
    "restClient"
    "sass"
    # "searchEverywhereMl"
    # "settingsSync"
    # "sh"
    "Spring"
    "spring-boot-cloud"
    "spring-boot-core"
    "spring-boot-initializr"
    "spring-data"
    "spring-integration-core"
    "spring-messaging"
    "spring-modulith"
    "spring-mvc-impl"
    "spring-security"
    "station-plugin"
    "styled-components"
    "stylelint"
    "swagger"
    "tailwindcss"
    # "tasks"
    # "tasks-timeTracking"
    # "terminal"
    "testng"
    "textmate"
    "thymeleaf"
    # "toml"
    "tslint"
    # "turboComplete"
    # "ultimate-plugin"
    # "uml"
    # "vcs-git"
    # "vcs-git-commit-modal"
    # "vcs-github-IU"
    "vcs-gitlab-IU"
    "vcs-hg"
    "vcs-perforce"
    "vcs-svn"
    "velocity"
    "vitejs"
    "vuejs"
    "webComponents"
    "webDeployment"
    # "webp"
    "webpack"
    # "xml-refactoring"
    # "xpath"
    # "yaml"

    # The LLDB debugger, requires lldb buildInput
    # which adds 850MB: clang.lib + lldb + lua
    "Kotlin/bin"

    # TODO: Why is it different from kotlinc.ide?
    # Gets symlinked later
    "Kotlin/kotlinc.ide"

    # Contains list of _all_ bundled plugins, IJ tries
    # to load them then complains about class not found
    "plugin-classpath.txt"
  ],
}:

stdenv.mkDerivation rec {

  pname = "idea-IU-unwrapped";

  version = "2025.2.3";
  buildNumber = "252.26830.84";

  dontUnpack = true;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIU-${version}.tar.gz";
    hash = "sha256-SlSuihfWQn8H0kUDJBMvWTkSecaxCU3gL3PkCN61ojw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # from buildIdea
  buildInputs = [
    stdenv.cc.cc
    musl
    # lldb

    # skiko renderer
    fontconfig
    libGL
    # xorg.libX11
  ];

  autoPatchelfIgnoreMissingDeps = [ "libX11.so.6" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    tar --gzip    \
      -f $src       \
      --extract       \
      -C $out           \
      --show-omitted-dirs \
      --strip-components=1  \
      --exclude-from <(
        echo "${lib.concatStringsSep "\nidea-IU-${buildNumber}/plugins/" removedPlugins}"
      ) \
      idea-IU-${buildNumber}/{bin,lib,modules,plugins,product-info.json}/

    cd $out

    # They ship two versions of the kotlin compiler
    # Maybe we can simply workaround that
    # TODO: Test
    ln -s kotlinc plugins/Kotlin/kotlinc.ide

    # TODO: Recreate removed sh's (format inspect ltedit)
    rm -f bin/{fsnotifier,idea,*.sh}
    # JetBrains Client is part of Code With Me
    rm -f bin/{jetbrains_client*,remote-dev-server*}

    # The remaining code is part of the original script

    ln -s ${jbr.home} jbr

    echo -Djna.library.path=${
      lib.makeLibraryPath [
        libsecret
        e2fsprogs # TODO: doesn't work, libe2p.so not found
        libnotify
        # Required for Help -> Collect Logs
        # in at least rider and goland
        udev
      ]
    } >> bin/idea64.vmoptions

    ln -s ${libdbusmenu}/lib/libdbusmenu-glib.so bin/libdbm.so
    ln -s ${fsnotifier}/bin/fsnotifier bin/fsnotifier

    runHook postInstall
  '';

  ## NOTE: Removed wrapper, so unwrapped.nix is unusable alone

  # TODO: combine with RustRover and Android Studio
  UNUSED_postFixup = ''
    cd $out/rust-rover

    # Copied over from clion (gdb seems to have a couple of patches)
    ls -d $PWD/bin/gdb/linux/*/lib/python3.8/lib-dynload/* |
    xargs patchelf \
      --replace-needed libssl.so.10 libssl.so \
      --replace-needed libcrypto.so.10 libcrypto.so

    ls -d $PWD/bin/lldb/linux/*/lib/python3.8/lib-dynload/* |
    xargs patchelf \
      --replace-needed libssl.so.10 libssl.so \
      --replace-needed libcrypto.so.10 libcrypto.so
  '';

}
#     rust-rover =
#       (mkJetBrainsProduct {
#         pname = "rust-rover";
#         extraBuildInputs = optionals (stdenv.hostPlatform.isLinux) [
#           python3
#           openssl
#           libxcrypt-legacy
#           fontconfig
#           # xorg.libX11
#         ];
#       }).overrideAttrs
#         (attrs: {
#         });

#     plugins = callPackage ./plugins { } // {
#       __attrsFailEvaluation = true;
#     };
