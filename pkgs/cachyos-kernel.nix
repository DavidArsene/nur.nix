{
  linuxKernel,
  linuxManualConfig,
  linuxPackagesFor,

  fetchFromGitHub,
  lib,
}:

let
  baseKernel = linuxKernel.kernels.linux_6_18;

  cachyosConfigs = fetchFromGitHub {
    owner = "CachyOS";
    repo = "linux-cachyos";
    rev = "e3fe7cb";
    hash = "";
  };

  cachyosPatches = fetchFromGitHub {
    owner = "CachyOS";
    repo = "kernel-patches";
    rev = "b8f46af";
    hash = "";

    sparseCheckout = [ patchesDir ];
  };

  patchesDir = "${cachyosPatches}/${baseKernel.version}/";

  #  cachyosKernel = linuxManualConfig {
  #    inherit (baseKernel) version modDirVersion src;
  #
  #    configfile = "${cachyosConfigs}/linux-cachyos/config";
  #
  #    kernelPatches = map (n: {
  #      name = n;
  #      patch = "${patchesDir}/${n}";
  #    }) patchNames;
  #  };

  cachyosKernel = baseKernel.override {
    pname = "linux-cachyos";

    # Allows overriding the default defconfig
    # defconfig = null;

    # Legacy overrides to the intermediate kernel config, as string
    # extraConfig = "";

    # Additional make flags passed to kbuild
    # extraMakeFlags = [ ];

    # enables the options in ./common-config.nix and lib/systems/platform.nix;
    # if `false` then only `structuredExtraConfig` is used
    # enableCommonConfig = true;

    # kernel intermediate config overrides, as a set
    # structuredExtraConfig = { };

    # A list of patches to apply to the kernel.  Each element of this list
    # should be an attribute set {name, patch} where `name' is a
    # symbolic name and `patch' is the actual patch.  The patch may
    # optionally be compressed with gzip or bzip2.
    kernelPatches =
      {
        "cachy-base" = "0001-cachyos-base-all.patch";
        # some scheds TODO:
        "acpi-call" = "misc/0001-acpi-call.patch";
        "clang-polly" = "misc/0001-clang-polly.patch";
      }
      |> lib.mapAttrs (
        name: patch: {
          inherit name;
          patch = "${patchesDir}/${patch}";
        }
      );

    extraMeta = { };
    extraPassthru = { };
  };

in
linuxPackagesFor cachyosKernel
