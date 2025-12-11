{
  stdenvNoCC,
  fetchgit,
  lib,

  # ! Always change hash when changing `blobs`
  blobs ? throw "no blobs specified",
  hash ? throw "no hash specified",
  tag ? throw "no tag specified",

  # Manually create symlinks or rename files
  # Traditionally done by WHENCE script
  extraSetup ? "",
}:

# TODO: what is "lib/firmware/edid not found, skipping."
stdenvNoCC.mkDerivation {
  pname = "firmware-minimal";
  version = tag;
  dontBuild = true;

  #! sudo dmesg | grep "Direct firmware load for"

  src = fetchgit {
    inherit hash tag;
    url = "https://gitlab.com/kernel-firmware/linux-firmware.git";
    name = "firmware-sparse-${tag}";

    sparseCheckout = blobs; # ++ [ "WHENCE" ];
    # In cone mode, sparse-checkout only sees directories, not individual files.
    # Without it, .git/info/sparse-checkout behaves identically to a reverse .gitignore
    nonConeMode = true;
  };

  installPhase = ''
    mkdir -p "$out/lib/firmware"
    cp -r -t "$out/lib/firmware" ./*

    cd "$out/lib/firmware"
    ${extraSetup}
  '';

  # The rest is part of the original package

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = {
    description = "Binary firmware blobs, specifically selected for minimal systems";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = lib.licenses.unfreeRedistributableFirmware;
    platforms = lib.platforms.linux;
    priority = 6; # give precedence to kernel firmware
  };
}
