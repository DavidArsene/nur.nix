{
  lib,
  fetchFromGitHub,
  wayland,
  wayland-protocols,
  libxkbcommon,
  glfw3,
}:
(glfw3.override { withMinecraftPatch = true; }).overrideAttrs (oldAttrs: {
  pname = "glfw-wayland";
  version = "3.5-unstable-2025-11-30";

  src = fetchFromGitHub {
    owner = "llyyr";
    repo = "glfw-minecraft-wayland";
    rev = "2f682232590211b0fd33407458be09e29c0e58f2";
    hash = "sha256-gaDkhS87ufOMZhOX7ChcqJs3UfWat9KYP+AKj3ypA7A=";
  };

  #? First 5 patches are added using prePatch on upstream
  patches = [
    # ./0001-Key-Modifiers-Fix.patch
    # ./0002-Fix-duplicate-pointer-scroll-events.patch
    # ./0003-Implement-glfwSetCursorPosWayland.patch
    # ./0004-Fix-Window-size-on-unset-fullscreen.patch
    # ./0005-Avoid-error-on-startup.patch
    # 0006 Add warning about being an unofficial patch
    ./0007-Fix-fullscreen-location.patch
    #? Not compatible with fork
    # ./0008-Fix-forge-crash.patch
  ];

  #? Not needed by fork
  prePatch = null;

  #? Overriden to remove X11 dependencies
  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
  ];

  cmakeFlags = oldAttrs.cmakeFlags ++ [
    # the wayland cult isn't real and can't hurt you
    (lib.cmakeBool "GLFW_BUILD_X11" false)
  ];

  meta = {
    description = "The same GLFW y'all know and love but extensively patched for Minecraft on Wayland (no X11 support)";
    homepage = "https://www.glfw.org/";
    license = lib.licenses.zlib;
    platforms = lib.platforms.unix;
  };
})
