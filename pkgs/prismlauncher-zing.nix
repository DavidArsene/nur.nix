{
  addDriverRunpath,
  callPackage,
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
}:

let
  prismlauncher' = prismlauncher-unwrapped.override { };

  java = callPackage ./zing.nix { };

  glfw-minecraft-wayland-fix = callPackage ./glfw-minecraft-wayland-fix { };
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
        glfw-minecraft-wayland-fix
        openal

        pipewire # openal
        libGL # glfw
        udev # oshi
        vulkan-loader # VulkanMod's lwjgl

        gamemode.lib
      ];

      runtimePrograms = [
        java # instead of PRISMLAUNCHER_JAVA_PATHS for nicer path
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
