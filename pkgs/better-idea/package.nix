{
  lib,
  callPackage,
  writeShellScriptBin,
  stdenv,
  makeDesktopItem,
  jq,

  gitMinimal,
  # gsettings-qt,
  procps,
  gnupg,
  libGL,
  zlib,

  libsecret,
  e2fsprogs,
  libnotify,
  udev,

  jetbrains,
  jbr' ? jetbrains.jdk-no-jcef,

  maven,
  mvn' ? maven.override { jdk_headless = jbr'; },

  extraPackages ? [ ],
  extraProperties ? { },
  extraArgs ? [ ],
}:

# TODO: sudo sh -c 'echo 1 > /proc/sys/kernel/perf_event_paranoid'
# sudo sh -c 'echo 0 > /proc/sys/kernel/kptr_restrict'

let
  # TODO: plugins from CLion:
  # diff -d \
  #   (jq -r .bundledPlugins[] idea-*/product-info.json | sort | psub) \
  #   (jq -r .bundledPlugins[] clion-*/product-info.json | sort | psub) | rg '>'

  app = callPackage ./idea-unwrapped.nix { iUsedTheWrapperCorrectly = true; };

  #? Moved here everything from the old postPatch
  #? combined with the original bin/idea.sh
  #? And turned the script wrapper around a script
  #? into a biblically accurate launcher
  launcherEnv = {

    #? Used in product-info.json
    IDE_HOME = app;

    LD_LIBRARY_PATH = lib.makeLibraryPath [
      libGL
      zlib
      udev # ! which one is needed?
    ];

    JAVA_HOME = jbr'.home;
    M2_HOME = "${mvn'}/maven";
    M2 = "${mvn'}/maven/bin";

    #? clion-radler's dotnet
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";
  };

  properties = extraProperties // {
    "jb.vmOptionsFile" = "$IDE_HOME/$(getMeta vmOptionsFilePath)";
    "awt.toolkit.name" = "WLToolkit";
    "jna.library.path" = lib.makeLibraryPath [
      libsecret
      e2fsprogs
      libnotify
      # > Required for Help -> Collect Logs
      # > in at least rider and goland
      udev
    ];

    # "idea.config.path" = "";
    # "idea.system.path" = "";
    # "idea.plugins.path" = "";
    # "idea.log.path" = "";
  };

  # TODO: System.getProperty && Boolean.getBoolean && Registry.*Value
  launcherArgs = [
    "$(eval echo $(getMeta additionalJvmArguments[]))"

    "-XX:ErrorFile=$HOME/java_error_in_idea_%p.log"
    "-XX:HeapDumpPath=$HOME/java_error_in_idea_.hprof"
  ]
  ++ lib.mapAttrsToList (k: v: "-D${k}=${v}") properties
  ++ extraArgs;

  launcherBin = writeShellScriptBin "idea.sh" ''
    _LAUNCH_META="$(${lib.getExe jq} .launch[0] ${app}/product-info.json)"
    getMeta() { ${lib.getExe jq} -r ".$1" <<< "$_LAUNCH_META"; }

    ${lib.toShellVars launcherEnv}

    export PATH+=":${
      lib.makeBinPath (
        [
          jbr'
          # gsettings-qt

          gitMinimal
          procps
          gnupg
        ]
        ++ extraPackages
      )
    }"
    _CLASSPATH="$IDE_HOME"/lib/'*' # Ignore bootClassPathJarNames
    exec java -cp "$_CLASSPATH" ${lib.concatStringsSep " \\\n" launcherArgs} $(getMeta mainClass) "$@"
  '';
in

stdenv.mkDerivation rec {
  pname = "jetbrains-idea";
  inherit (app) version buildNumber;

  meta = {
    homepage = "https://www.jetbrains.com/idea/";
    description = "${version} ${buildNumber}";
    teams = [ lib.teams.jetbrains ];
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };

  desktopItem = makeDesktopItem {
    name = pname;
    icon = pname;
    exec = lib.getExe launcherBin;
    comment = meta.description;
    desktopName = "IntelliJ IDEA";
    categories = [ "Development" ];
    startupWMClass = pname; # ! launchMeta.startupWmClass;
  };

  dontUnpack = true;
  src = null;

  installPhase = ''
    mkdir -p $out/{bin,share/pixmaps,share/icons/hicolor/scalable/apps}

    ln -s ${lib.getExe launcherBin} $out/bin/idea

    ln -s "${app}/bin/idea.png" $out/share/pixmaps/${pname}.png
    ln -s "${app}/bin/idea.svg" $out/share/pixmaps/${pname}.svg
    ln -s "${app}/bin/idea.svg" $out/share/icons/hicolor/scalable/apps/${pname}.svg
    ln -s "${desktopItem}/share/applications" $out/share
  '';
}
