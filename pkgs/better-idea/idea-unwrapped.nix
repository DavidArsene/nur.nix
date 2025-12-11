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

  python3,
  openssl,
  libxcrypt-legacy,
  lttng-ust_2_12,

  libdbusmenu,
  fsnotifier,

  # # Create new plugin list for diffing
  # tar tf *ideaIU-*.tar.gz --exclude='*-*/plugins/*/*' *-*/plugins/ | xargs -n1 basename | sort | uniq
  removedPlugins ? [
    # "android-gradle-declarative-lang-ide"
    # "android-gradle-dsl"
    "angular"
    "aopCommon"
    "clouds-docker-gateway"
    "clouds-docker-impl"
    "clouds-kubernetes"
    # "completionMlRanking"
    "compose-ide-plugin"
    "configurationScript"
    "copyright" # ?
    "cron" # ?
    "css-impl"
    "css-plugin"
    "cwm-plugin"
    "DatabaseTools"
    "debugger-collections-visualizer"
    # "dev"
    "eclipse"
    "editorconfig-plugin" # ?
    "featuresTrainer"
    # "findUsagesMl"
    "flyway"
    "freemarker"
    "fullLine"
    "gateway-plugin"
    # "gradle"
    "gradle-java" # ?
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
    "JavaeeWeb"
    "javaFX"
    # "java-i18n"
    # "java-ide-customization"
    "javascript-debugger"
    "javascript-intentions"
    "javascript-plugin"
    "JPA"
    "JPA Model"
    # "json"
    "jsonpath" # ?
    "junit"
    "jupyter-plugin"
    "karma"
    "keymap-eclipse"
    "keymap-netbeans"
    "keymap-visualStudio"
    # "Kotlin"
    "kotlin-jupyter-plugin"
    "ktor"
    "less"
    "liquibase"
    "localization-ja"
    "localization-ko"
    "localization-zh"
    "lombok"
    # "markdown"
    "maven"
    "mcpserver"
    "micronaut"
    "microservices-jvm"
    "microservices-plugin"
    "nextjs"
    "nodeJS"
    "nodeJS-remoteInterpreter"
    "notebooks-plugin"
    "packageChecker"
    # "performanceTesting"
    # "performanceTesting-async"
    "platform-ijent-impl"
    # "platform-images"
    "postcss"
    "prettierJS"
    # "profiler-lineProfiler"
    "properties" # ?
    "protoeditor" # ?
    "qodana"
    "quarkus"
    "react"
    "reactivestreams-core"
    "remote-dev-server"
    "remoteRun" # ?
    "repository-search"
    "restClient"
    "sass-plugin"
    # "searchEverywhereMl"
    # "settingsSync"
    "sh-plugin" # ?
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
    "tasks" # ?
    "tasks-timeTracking"
    # "terminal"
    "testng"
    "textmate-plugin"
    "thymeleaf-plugin"
    "toml" # ?
    "tslint"
    # "turboComplete"
    # "ultimate-plugin"
    # "uml"
    # "vcs-git" #* only updated in bundled builds
    "vcs-git-commit-modal"
    "vcs-github" # ?
    "vcs-hg"
    "vcs-perforce"
    "vcs-svn"
    "velocity"
    "vitejs"
    "vuejs-plugin"
    "webComponents"
    "webDeployment"
    "webpack"
    "xml-refactoring"
    "xpath"
    "yaml" # ?

    # Contains list of _all_ bundled plugins, IJ tries
    # to load them then complains about class not found
    "plugin-classpath.txt"
  ],
}:

#! http://localhost:63342/api/installPlugin?action=install&pluginIds=[com.intellij.configurationScript,com.intellij.modules.ultimate]

stdenv.mkDerivation rec {

  # !NOTE: Removed wrapper, so unwrapped.nix is unusable alone
  pname = "idea-IU-unwrapped";

  version = "2025.3";
  buildNumber = "253.28294.334";

  dontUnpack = true;
  src = fetchurl {
    url = "https://download.jetbrains.com/idea/ideaIU-${version}.tar.gz";
    hash = "sha256-E/QXS6FsHO8EhxyyYUM1NtACWGwmmoCTksIO4/lJWfU=";
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
  ]
  # CLion and RustRover
  ++ lib.optionals false [
    python3
    openssl
    libxcrypt-legacy
    lttng-ust_2_12
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

    # ! NEW CLION
    if false; then

    for dir in $out/clion/plugins/clion-radler/DotFiles/linux-*; do
      rm -rf $dir/dotnet
      ln -s ''${dotnet-sdk}/share/dotnet $dir/dotnet
    done

    # postFixup
    ls -d \
      $out/*/bin/*/linux/*/lib/liblldb.so \
      $out/*/bin/*/linux/*/lib/python3.8/lib-dynload/* \
      $out/*/plugins/*/bin/*/linux/*/lib/liblldb.so \
      $out/*/plugins/*/bin/*/linux/*/lib/python3.8/lib-dynload/* |
    xargs patchelf \
      --replace-needed libssl.so.10 libssl.so \
      --replace-needed libssl.so.1.1 libssl.so \
      --replace-needed libcrypto.so.10 libcrypto.so \
      --replace-needed libcrypto.so.1.1 libcrypto.so \
      --replace-needed libcrypt.so.1 libcrypt.so

    # DONE
    fi;


    # They ship two versions of the kotlin compiler
    # Maybe we can simply workaround that
    # TODO: Test
    # ln -s kotlinc.ide plugins/Kotlin/kotlinc

    # TODO: Recreate removed sh's (format inspect ltedit)
    rm -f bin/{fsnotifier,idea,*.sh}
    # JetBrains Client is part of Code With Me
    rm -f bin/{jetbrains_client*,remote-dev-server*}

    # The remaining code is part of the original script

    # Moved to wrapper env
    # Allegedly used by Remote Gateway
    # ln -s ''${jbr.home} jbr

    ln -s ${libdbusmenu}/lib/libdbusmenu-glib.so bin/libdbm.so
    ln -s ${fsnotifier}/bin/fsnotifier bin/fsnotifier

    runHook postInstall
  '';
}

# plugins = callPackage ./plugins { } // {
#   __attrsFailEvaluation = true;
# };
