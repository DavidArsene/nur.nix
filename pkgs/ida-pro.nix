{
  ida-free,
  requireFile,
  python313,
  #libxcrypt,
  libxcrypt-legacy,
}:

let
  # https://github.com/msanft/ida-pro-overlay/blob/main/packages/ida-pro.nix
  #idapy = python3.withPackages (ps: with ps; [ rpyc ]);
in

# Everything in ida-free applies here as well
(ida-free.overrideAttrs (oldAttrs: rec {
  pname = "ida-pro";
  version = "9.3sp1";

  src = requireFile rec {
    message = ''
      Legally download the installer: ${name}

      Then add it to the nix store:
      $ nix store prefetch-file file://...

      The hash should match this:
      ${hash}
    '';
    name = "ida-pro_93_x64linux.run";
    hash = "sha256-CVv1EUt2RSNqHuQ7ZfZKyn2jM368bn+XmQd9tvWM0wc=";
  };

  # Bugfix
  runtimeDependencies = oldAttrs.runtimeDependencies ++ [
    #"libcrypt.so.1" # FIXME:
    #"libxcrypt.so.1" # FIXME:
    python313
    #libxcrypt
    libxcrypt-legacy
  ];

  #qtWrapperArgs = [
  # ''--run "$out/opt/*/idapyswitch -s ${idapy}/lib/libpython3.*.so"''
  #"--prefix PATH : ${idapy}/bin"
  #];

  preFixup = ''
    IDADIR=$out/opt/${pname}-${version}

    # ida-pro-overlay start
    for lib in $IDADIR/*.so $IDADIR/*.so.6; do
      ln -sf $lib $out/lib/$(basename $lib)
    done

    #patchelf --add-needed libpython3.13.so $out/lib/libida.so
    #patchelf --add-needed libsecret-1.so.0 $out/lib/libida.so
    # ida-pro-overlay end
    #patchelf --add-needed libxcrypt.so.1 $out/lib/libida.so
    patchelf --replace-needed libxcrypt.so.1 libcrypt.so.1 $out/lib/libida.so

    echo -e 'Categories=Development;\nStartupWMClass=IDA;' \
      >> $out/share/applications/com.hex_rays.IDA.pro.*.desktop

    pushd $IDADIR
    cp ida.hlp $out/lib/
    rm -v cfg/pic*.cfg
    rm -v ?ninstall*
    rm -r docs/
  '';
})).override
  {
    hexPatches = [
      {
        filename = "libida.so";
        from = "edfd425c";
        to = "edfd42cb";
        assertCount = 2;
      }
    ];
  }
