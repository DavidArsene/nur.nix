{
  lib,
  ida-free,
  python3Minimal,
  requireFile,
}:

# Everything in ida-free applies here as well
ida-free.overrideAttrs (oldAttrs: rec {
  pname = "ida-pro";
  version = "9.2";
  # also change version in keygen.py product_version

  src = requireFile rec {
    message = "Obtain the installer somehow: ${name}";
    name = "ida-pro_${lib.replaceStrings [ "." ] [ "" ] version}_x64linux.run";
    hash = "sha256-qt0PiulyuE+U8ql0g0q/FhnzvZM7O02CdfnFAAjQWuE=";
  };

  # Bugfix
  autoPatchelfIgnoreMissingDeps = oldAttrs.autoPatchelfIgnoreMissingDeps ++ [
    "libQt6WaylandCompositor.so.6"
  ];

  postFixup = ''
    IDADIR=$out/opt/${pname}-${version}
    pushd $IDADIR

    # 0x5C just so happens to represent "\", and guess what
    # it's converted first then parsed in the regex
    # before='\xED\xFD\x42\x5C'

    before='\xED\xFD\x42\\'
    after='\xED\xFD\x42\xCB'

    for file in $out/lib/libida.so ./libida.so; do
      echo "Patching $file"
      sed -i "s/$before/$after/" $file
    done

    cp ida.hlp $out/lib/
    rm -v cfg/pic*.cfg
    rm -vf ./{.assistant-*,assistant,?ninstall*}
    rm -vf $out/bin/assistant

    ${python3Minimal}/bin/python ${./keygen.py}
  '';
})
