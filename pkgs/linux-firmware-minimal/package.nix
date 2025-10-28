{
  stdenvNoCC,
  fetchgit,
  lib,

  blobs ? throw,
  hash ? throw,
  tag ? throw,
}:

stdenvNoCC.mkDerivation {
  pname = "linux-firmware-minimal";
  version = tag;
  dontBuild = true;

  #! dmesg | rg "Direct firmware load for"

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
    mv -v -t "$out/lib/firmware" ./*
  '';

  # The rest is part of the original package

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = with lib; {
    description = "Binary firmware blobs, specifically selected for minimal systems";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    priority = 6; # give precedence to kernel firmware
  };
}
