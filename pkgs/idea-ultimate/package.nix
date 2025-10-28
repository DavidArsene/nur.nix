{
  lib,
  callPackage,
  writeShellScriptBin,
  stdenv,
  makeDesktopItem,

  gitMinimal,
  procps,
  libGL,
  zlib,
  # glibcLocales,

  jetbrains,
  jbr ? jetbrains.jdk,

  maven,
  mvn' ? maven.override { jdk_headless = jbr; },

  extraProperties ? { },
  extraArgs ? [ ],
}:

with lib;
let
  join = concatStringsSep;

  #> Ugh IFD, couldn't come up with a better method
  #> Dynamic that is, I ain't sitting around running update scripts
  app = (callPackage ./unwrapped.nix { inherit jbr; }).out;

  product-info = trivial.importJSON "${app}/product-info.json";
  launchMeta = lists.head product-info.launch;
  classpath = launchMeta.bootClassPathJarNames |> map (p: "$IDE_HOME/lib/${p}") |> join ":";

  #> Moved here everything from the old postPatch
  #> combined with the original bin/idea.sh
  #> And turned the script wrapper around a script
  #> into a biblically accurate launcher
  launcherEnv = {

    #> Used throughout the script for shorter paths
    IDE_HOME = app;

    LD_LIBRARY_PATH = makeLibraryPath [
      libGL
      zlib
    ];

    M2_HOME = "${mvn'}/maven";
    M2 = "${mvn'}/maven/bin";

    # LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive"
  };

  extraPath = makeBinPath [
    jbr
    gitMinimal
    procps
  ];

  properties = extraProperties // {
    "jb.vmOptionsFile" = "$IDE_HOME/${launchMeta.vmOptionsFilePath}";
    "awt.toolkit.name" = "WLToolkit";

    # "idea.config.path" = "";
    # "idea.system.path" = "";
    # "idea.plugins.path" = "";
    # "idea.log.path" = "";
  };

  vmoptions = extraArgs ++ [
    "-XX:ErrorFile=$HOME/java_error_in_idea_%p.log"
    "-XX:HeapDumpPath=$HOME/java_error_in_idea_.hprof"
  ];

  # TODO: System.getProperty && Boolean.getBoolean
  launcherArgs =
    launchMeta.additionalJvmArguments
    ++ (map (k: "-D${k}=${properties.${k}}") (attrNames properties))
    ++ vmoptions;

  #> They do really have obscure specialized functions for everything
  launcherBin = writeShellScriptBin "idea" ''
    ${toShellVars launcherEnv}
    PATH="$PATH:${extraPath}"

    exec java -cp ${classpath} ${join " \\\n" launcherArgs} ${launchMeta.mainClass} "$@"
  '';
in

stdenv.mkDerivation rec {
  pname = "idea-ultimate";
  version = product-info.version;

  meta = {
    homepage = "https://www.jetbrains.com/idea/";
    description = "All-In-One IDE tailored by and for David";
    teams = [ teams.jetbrains ];
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
  };

  desktopItem = makeDesktopItem {
    name = pname;
    icon = pname;
    exec = "${launcherBin}/bin/idea";
    comment = meta.description;
    desktopName = "IntelliJ IDEA Ultimate";
    categories = [ "Development" ];
    startupWMClass = launchMeta.startupWmClass;
  };

  dontUnpack = true;
  src = null;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/pixmaps,share/icons/hicolor/scalable/apps}

    ln -s ${launcherBin}/bin/idea $out/bin/idea

    ln -s "${app}/bin/idea.png" $out/share/pixmaps/${pname}.png
    ln -s "${app}/bin/idea.svg" $out/share/pixmaps/${pname}.svg
    ln -s "${app}/bin/idea.svg" $out/share/icons/hicolor/scalable/apps/${pname}.svg
    ln -s "${desktopItem}/share/applications" $out/share

    runHook postInstall
  '';
}
