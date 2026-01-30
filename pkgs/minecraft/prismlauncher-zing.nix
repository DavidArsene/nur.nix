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

  glfw-wayland,
  azul-zing,
}:

symlinkJoin {
  pname = "prismlauncher-zing";
  inherit (prismlauncher-unwrapped) version;

  paths = [ prismlauncher-unwrapped ];

  nativeBuildInputs = [ kdePackages.wrapQtAppsHook ];

  buildInputs = with kdePackages; [
    qtbase
    qtimageformats
    qtsvg
    qtwayland
  ];

  postBuild = ''
    wrapQtAppsHook
  '';

  qtWrapperArgs =
    let
      runtimeLibs = [
        (lib.getLib stdenv.cc.cc)
        ## native versions
        glfw-wayland
        openal

        pipewire # openal
        libGL # glfw
        udev # oshi
        vulkan-loader # VulkanMod's lwjgl

        gamemode.lib
      ];

      runtimePrograms = [
        azul-zing # instead of PRISMLAUNCHER_JAVA_PATHS for nicer path
        pciutils # uses lspci
      ];

    in
    [
      "--set LD_LIBRARY_PATH ${addDriverRunpath.driverLink}/lib:${lib.makeLibraryPath runtimeLibs}"
      "--prefix PATH : ${lib.makeBinPath runtimePrograms}"
    ];

  meta = {
    inherit (prismlauncher-unwrapped.meta)
      homepage
      changelog
      license
      mainProgram
      ;
    description = "Prism Launcher configured with Zing JVM and patched GLFW";
    platforms = [ "x86_64-linux" ];
  };
}
