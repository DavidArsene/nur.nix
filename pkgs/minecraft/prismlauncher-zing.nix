{
  addDriverRunpath,
  gamemode,
  kdePackages,
  lib,
  libGL,
  openal,
  pciutils,
  pipewire,
  prismlauncher-unwrapped,
  stdenv,
  symlinkJoin,
  udev,
  vulkan-loader,

  glfw-minecraft-wayland,
  zing-jre,
}:

let
  prismlauncher' = prismlauncher-unwrapped.override { };
in

symlinkJoin {
  name = "prismlauncher-zing-${prismlauncher'.version}";

  paths = [ prismlauncher' ];

  nativeBuildInputs = [ kdePackages.wrapQtAppsHook ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtsvg
    kdePackages.qtwayland
  ];

  postBuild = ''
    wrapQtAppsHook
  '';

  qtWrapperArgs =
    let
      runtimeLibs = [
        (lib.getLib stdenv.cc.cc)
        ## native versions
        glfw-minecraft-wayland
        openal

        pipewire # openal
        libGL # glfw
        udev # oshi
        vulkan-loader # VulkanMod's lwjgl

        gamemode.lib
      ];

      runtimePrograms = [
        zing-jre # instead of PRISMLAUNCHER_JAVA_PATHS for nicer path
        pciutils # uses lspci
      ];

    in
    [
      "--set LD_LIBRARY_PATH ${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}"
      "--prefix PATH : ${lib.makeBinPath runtimePrograms}"
    ];

  meta = {
    inherit (prismlauncher'.meta)
      homepage
      changelog
      license
      mainProgram
      ;
    description = "Prism Launcher configured with Zing JVM and patched GLFW";
    platforms = [ "x86_64-linux" ];
  };
}
