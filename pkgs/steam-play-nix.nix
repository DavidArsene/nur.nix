{
  buildFHSEnv,
  lib,
  stdenvNoCC,
  writeText,
  multiArch ? false,
  ...
}:
let
  me = "steam-play-nix";
  targetPkgs =
    pkgs: with pkgs; [
      # https://repo.steampowered.com/steamrt4/images/4.0.20260714.251823/com.valvesoftware.SteamRuntime.Platform-amd64%2Ci386-steamrt4.source-required.txt
      acl # 2.3.2-2
      alsa-lib # 1.2.14-1
      alsa-plugins # 1.2.12-2+steamrt4.1
      #! apparmor # 4.1.0-1
      apt # 3.0.3
      at-spi2-core # 2.56.2-1+deb13u1
      attr # 1:2.5.2-3
      audit # 1:4.0.2-2
      avahi # 0.8-16
      #! base-files # 13.8+steamrt4.1+deb13u6
      #! base-passwd # 3.6.7
      bash # 5.2.37-2+steamrt4.1
      brotli # 1.1.0-2
      bzip2 # 1.0.8-6
      cacert # ! ca-certificates # 20250419
      cairo # 1.18.4-1+steamrt4.1
      #! cdebconf # 0.280
      coreutils # 9.7-3
      cups # 2.4.10-3+deb13u2
      curl # 8.14.1-2+steamrt4.1+deb13u4
      dash # 0.5.12-12
      dav1d # 1.5.1-1
      db5 # 5.3.28+dfsg2-9
      dbus # 1.16.2-2
      dconf # 0.40.0-5+steamrt4.1
      #! debconf # 1.5.91
      #! debian-archive-keyring # 2025.1
      debianutils # 5.23.2
      diffutils # 1:3.10-4
      dpkg # 1.22.22
      duktape # 2.7.0-2
      dxvk # 2.7.1-2+steamrt3.1
      e2fsprogs # 1.47.2-3
      elfutils # 0.192-4
      expat # 2.7.1-2
      file # 1:5.46-5
      findutils # 4.10.0-3
      flac # 1.5.0+ds-2
      flatpak-xdg-utils # 1.0.6-1
      flex # 2.6.4-8.2
      fontconfig # 2.15.0-2.3
      dejavu_fonts # 2.37-8
      freetype # 2.13.3+dfsg-1+deb13u1
      fribidi # 1.0.16-1
      #* gcc14 # 14.2.0-19
      gdb # 16.3-1
      gdk-pixbuf # 2.42.12+dfsg-4+deb13u1
      glib-networking # 2.80.1-1
      glib # glib2.0 # 2.84.4-3~deb13u3
      glibc # 2.41-12+deb13u3
      gmp # 2:6.3.0+dfsg-3
      gnutls # 3.8.9-3+deb13u4
      graphene # 1.10.8-5
      graphite2 # 1.3.14-2+deb13u1
      gnugrep # 3.11-4
      gsettings-desktop-schemas # 48.0-1
      gzip # 1.13-1
      harfbuzz # 10.2.0-1+deb13u1
      hostname # 3.25
      hwloc # 2.12.0-4
      #! init-system-helpers # 1.69~deb13u1
      json-glib # 1.10.6+ds-2
      keyutils # 1.6.3-6
      kmod # 34.2-2
      krb5 # 1.21.3-5+deb13u1
      libasyncns # 0.8-6
      libbsd # 0.12.2-2
      libcap_ng # 0.8.5-4
      libcap # 1:2.75-10+deb13u1
      libdatrie # 0.2.13-3
      libdecor # 0.2.2-2
      libdeflate # 1.23-2
      libdrm # 2.4.124-2
      libffi # 3.4.8-2
      libgcrypt # 1.11.0-7+deb13u1
      libglvnd # 1.7.0-1
      libgpg-error # 1.51-4
      libgudev # 238-6
      libice # 2:1.1.1-1
      libidn2 # 2.3.8-2
      libjpeg_turbo # 1:2.1.5-4
      jsoncpp # 1.9.6-3
      libmd # 1.1.0-2
      libnotify # 0.8.6-1
      libogg # 1.3.5-3
      libpciaccess # 0.17-3
      libpng # 1.6.48-1+deb13u5
      libproxy # 0.5.9-1
      libpsl # 0.21.2-1.1
      libsamplerate # 0.2.2-4
      sdl3 # 3.4.12+ds-1+steamrt4.1
      sdl3-image # 3.4.4+ds-1~steamrt3.1
      sdl3-mixer # 3.2.4+ds-1~steamrt3.1
      sdl3-net # 3.2.0+ds-1~steamrt3.1
      sdl3-ttf # 3.2.2+ds-1
      libseccomp # 2.6.0-2
      libselinux # 3.8.1-1
      libsemanage # 3.8.1-1
      libsepol # 3.8.1-1
      libsm # 2:1.2.6-1
      libsndfile # 1.2.2-2+steamrt4.1+deb13u1
      libsoup_3 # 3.6.5-3
      libssh2 # 1.11.1-1+deb13u1
      libtasn1 # 4.20.0-2+deb13u1
      libthai # 0.1.29-2
      libtheora # 1.2.0~alpha1+dfsg-6
      libunistring # 1.3-2
      libusb1 # 2:1.0.28-1
      libutempter # 1.2.1-4
      libva # 2.22.0-3
      libva-utils # 2.22.0+ds1-2
      libvdpau # 1.5-3
      libvorbis # 1.3.7-3
      libvpx # 1.15.0-2.1+deb13u1
      libwebp # 1.5.0-0.1
      libx11 # 2:1.8.12-1
      libxau # 1:1.0.11-1
      libxaw # 2:1.0.16-1
      libxcb # 1.17.0-2
      libxcomposite # 1:0.4.6-1
      libxcrypt # 1:4.4.38-1
      libxcursor # 1:1.2.3-1
      libxdamage # 1:1.1.6-1
      libxdmcp # 1:1.1.5-1
      libxext # 2:1.3.4-1
      libxfixes # 1:6.0.0-2
      libxi # 2:1.8.2-1
      libxinerama # 2:1.1.4-3
      libxkbcommon # 1.7.0-2
      libxkbfile # 1:1.1.0-1
      libxml2 # 2.12.7+dfsg+really2.9.14-2.1+deb13u3
      libxmu # 2:1.1.3-3
      #! libxnvctrl # 535.171.04-1
      libxpm # 1:3.5.17-1+deb13u1
      libxpresent # 1.0.1-1
      libxrandr # 2:1.5.4-1
      libxrender # 1:0.9.12-1
      libxshmfence # 1.3.3-1
      libxscrnsaver # 1:1.2.3-1
      libxt # 1:1.2.1-1.2
      libxtst # 2:1.2.5-1
      libxxf86vm # 1:1.1.4-1
      zstd # 1.5.7+dfsg-1
      lm_sensors # 1:3.6.2-2
      lz4 # 1.10.0-4
      mawk # 1.3.4.20250131-1
      #! media-types # 13.0.0
      mesa # 25.0.7-2+steamrt4.1+deb13u1
      mpg123 # 1.32.10-1+deb13u1
      ncurses # 6.5+20250216-2
      #! netbase # 6.5
      nettle # 3.10.1-1
      nghttp2 # 1.64.0-1.1+deb13u1
      nghttp3 # 1.8.0-1
      ngtcp2 # 1.11.0-1+deb13u1
      nspr # 2:4.36-1
      nss # 2:3.110-1+deb13u3
      onetbb # 2022.1.0-1+deb13u1
      openal-soft # 1:1.24.2-1+steamrt4.1
      openblas # 0.3.29+ds-3
      openssl # 3.5.6-1~deb13u2
      #! openxr-sdk-source # 1.1.47~ds-2
      opus # 1.5.2-2
      opusfile # 0.12-4
      p11-kit # 0.25.5-3
      pam # 1.7.0-5
      pango # 1.56.3-1
      #! pci.ids # 0.0~2025.06.09-1
      pciutils # 1:3.13.0-2
      pcre2 # 10.46-1~deb13u1
      pcsclite # 2.3.3-1
      perl # 5.40.1-6
      pipewire # 1.4.2-1+steamrt4.1
      pixman # 0.44.0-3
      pulseaudio # 17.0+dfsg1-2
      #! python3-defaults # 3.13.5-1
      python313 # 3.13.5-2+deb13u3
      readline # 8.2-6
      #! rust-buffered-reader # 1.3.1-2
      #! rust-nettle # 7.3.0-1
      #! rust-nettle-sys # 2.3.1-1
      #! rust-sequoia-openpgp # 2.0.0-2+deb13u1
      #! rust-sequoia-policy-config # 0.8.0-1
      #! rust-sequoia-sqv # 1.3.0-3
      #! rustc # 1.85.0+dfsg3-1
      sdl2-compat # 2.32.70+ds-1~steamrt4.1
      gnused # 4.9-2+deb13u1
      shadow # 1:4.17.4-2
      shared-mime-info # 2.4-5
      speex # 1.2.1-3
      speexdsp # 1.2.1-3
      sqlite # 3.46.1-7+deb13u1
      #! steam-runtime-tools # 0.20260714.0
      #! steamrt # 4.20260615.0
      # steamrt-archive-keyring # 0.20250818.0
      sudo # 1.9.16p2-3+deb13u2
      systemd # 257.13-1~deb13u1
      sysvinit # 3.14-4
      gnutar # 1.35+dfsg-3.1
      libtiff # 4.7.0-3+steamrt4.1+deb13u2
      tzdata # 2026b-0+deb13u1
      util-linux # 2.41-5
      v4l-utils # 1.30.1-1
      #* vkd3d # 2.0~steamrt-0+steamrt3.1
      vulkan-loader # 1.4.309.0-1
      vulkan-tools # 1.4.304.0+dfsg1-1
      waffle # 1.8.1-1
      wayland # 1.23.1-3
      #! what-is-python # 15
      xbitmaps # 1.1.1-2.2
      libxcb-util # 0.4.1-1
      libxcb-cursor # 0.1.5-1
      libxcb-image # 0.4.0-2
      libxcb-keysyms # 0.4.1-1
      libxcb-render-util # 0.3.10-1
      libxcb-wm # 0.4.2-1
      libxft # 2.3.6-1
      xkeyboard-config # 2.42-1
      #! xorg # 1:7.7+24+deb13u1
      xterm # 398-1
      xxhash # 0.8.3-2
      xz # 5.8.1-1+deb13u1
      zlib # 1:1.3.dfsg+really1.3.1-1
    ];

  rt = buildFHSEnv {
    pname = "${me}-rt";
    version = "4.0.20260714";

    #? x64 only, libs + bins
    inherit multiArch targetPkgs;

    # includeClosures = true;

    #? x64 and x86 (if multiArch), only libs
    # multiPkgs = pkgs: with pkgs; [ ];
  };

  vdf.compatibilitytool = writeText "compatibilitytool.vdf" ''
    "compatibilitytools"
    {
      "compat_tools"
      {
        "${me}" // Internal name of this tool
        {
          "install_path" "."
          "display_name" "${me}"
          "from_oslist"  "linux"
          "to_oslist"    "linux"
        }
      }
    }
  '';

  vdf.toolmanifest = writeText "toolmanifest.vdf" ''
    "manifest"
    {
      "version" "2"
      "commandline" "${lib.getExe rt}" // %verb%"
      "use_tool_subprocess_reaper" "0"
    }
  '';

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = me;
  inherit (rt) version;

  strictDeps = true;
  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    install -Dt $steamcompattool ${vdf.compatibilitytool} ${vdf.toolmanifest}
  '';

  passthru = { inherit rt; };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on native Nix packages.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    platforms = lib.platforms.linux;
  };
})
