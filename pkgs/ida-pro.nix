{
  ida-free,
  requireFile,
  python3Minimal,
}:

# Everything in ida-free applies here as well
ida-free.overrideAttrs (oldAttrs: rec {
  pname = "ida-pro";
  version = "9.3";

  src = requireFile rec {
    message = ''
      Legally download the installer: ${name}

      Then add it to the nix store:
      $ nix store prefetch-file file://...

      The hash should match this:
      ${hash}
    '';
    name = "ida-pro_93_x64linux.run";
    hash = "sha256-LtQ65LuE103K5vAJkhDfqNYb/qSVL1+aB6mq4Wy3D4I=";
  };

  # Bugfix
  autoPatchelfIgnoreMissingDeps = oldAttrs.autoPatchelfIgnoreMissingDeps ++ [
    "libQt6WaylandCompositor.so.6"
  ];

  # The python path to use is stored in $HOME/.idapro/ida.reg, which
  # uses the Windows registry format (iiuc) thus isn't easily editable.
  # So, without simpler ways of changing it, or having a default
  # reg file in the install dir, I had to do this at runtime.
  preFixup = ''
    qtWrapperArgs+=(
      --run
      "$out/opt/*/idapyswitch -s ${python3Minimal}/lib/libpython3.*.so"
    )
  '';

  postFixup = ''
    IDADIR=$out/opt/${pname}-${version}
    pushd $IDADIR

    echo 'Categories=Development;' >> $out/share/applications/com.hex_rays.IDA.pro.*.desktop
    cp ida.hlp $out/lib/
    rm -v cfg/pic*.cfg
    rm -v ?ninstall*
    rm -r docs/
  '';
})
