{
  lib,
  callPackage,
  writeShellScriptBin,
  stdenvNoCC,
  makeDesktopItem,
  jq,

  gitMinimal,
  procps,
  gnupg,
  libGL,
  zlib,

  libsecret,
  e2fsprogs,
  libnotify,
  udev,

  jetbrains ? null,
  jbr' ? jetbrains.jdk-no-jcef,

  extraEnv ? { },
  extraPackages ? [ ],
  extraProperties ? { },
  extraArgs ? [ ],

  package ? callPackage ./idea-unwrapped.nix { },
}:

let
  properties = {
    "jb.vmOptionsFile" = "$IDE_HOME/$(getMeta vmOptionsFilePath)";
    "awt.toolkit.name" = "WLToolkit";
    "nosplash" = "false"; # Force splash screen on Wayland
    "jna.library.path" = lib.makeLibraryPath [
      libsecret
      e2fsprogs
      libnotify
      # > Required for Help -> Collect Logs
      # > in at least rider and goland
      udev
    ];
  }
  // extraProperties;

  launcherEnv = {
    #? Used in product-info.json
    IDE_HOME = package;

    LD_LIBRARY_PATH = lib.makeLibraryPath [
      libGL
      zlib
      udev # ! which one is needed?
      libsecret
    ];

    # FIXME: https://github.com/NixOS/nixpkgs/issues/547183#issuecomment-5122868991
    JAVA_HOME = "${jbr'}/lib/openjdk";
    # M2_HOME = "${mvn'}/maven";
    # M2 = "${mvn'}/maven/bin";

    #? clion-radler's dotnet
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = 1;
  }
  // extraEnv;

  launcherPath = lib.makeBinPath (
    [
      gitMinimal
      procps
      gnupg

      jq # for the launcher itself
    ]
    ++ extraPackages
  );

  # TODO: System.getProperty && Boolean.getBoolean && Registry.*Value
  launcherArgs = [
    "$(eval echo $(getMeta additionalJvmArguments[]))"

    "-XX:ErrorFile=$HOME/java_error_in_idea_%p.log"
    "-XX:HeapDumpPath=$HOME/java_error_in_idea_.hprof"
  ]
  ++ lib.mapAttrsToList (k: v: "-D${k}=${v}") properties
  ++ extraArgs;

  # https://github.com/JetBrains/intellij-community/blob/master/platform/build-scripts/resources/linux/scripts/executable-template.sh
  launcherBin = writeShellScriptBin "idea.sh" ''

    set -a # Automatically export everything
    ${lib.toShellVars launcherEnv}
    PATH+=':${launcherPath}'
    set +a

    _LAUNCH_META="$(jq .launch[0] ${package}/product-info.json)"
    getMeta() { jq -r ".$1" <<< "$_LAUNCH_META"; }

    _CLASSPATH=$(getMeta 'bootClassPathJarNames | map("'$IDE_HOME'/lib/" + .) | join(":")')
    exec ${lib.getExe jbr'} -cp $_CLASSPATH ${lib.concatStringsSep " \\\n" launcherArgs} $(getMeta mainClass) "$@"
  '';
in

stdenvNoCC.mkDerivation rec {
  pname = "jetbrains-idea";
  inherit (package) version;

  meta = {
    homepage = "https://www.jetbrains.com/idea";
    description = version;
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
    startupWMClass = pname;
  };

  dontUnpack = true;
  src = null;

  installPhase = ''
    mkdir -p $out/{bin,share/pixmaps,share/icons/hicolor/scalable/apps}

    ln -s ${lib.getExe launcherBin} $out/bin/idea

    ln -s "${package}/bin/idea.png" $out/share/pixmaps/${pname}.png
    ln -s "${package}/bin/idea.svg" $out/share/pixmaps/${pname}.svg
    ln -s "${package}/bin/idea.svg" $out/share/icons/hicolor/scalable/apps/${pname}.svg
    ln -s "${desktopItem}/share/applications" $out/share
  '';
}

# TODO: sudo sh -c 'echo 1 > /proc/sys/kernel/perf_event_paranoid'
# TODO: sudo sh -c 'echo 0 > /proc/sys/kernel/kptr_restrict'
