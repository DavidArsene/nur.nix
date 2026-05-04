{ wineWow64Packages }:

(wineWow64Packages.staging.override {
  # TODO: and tkg with .cfg

  #? Descriptions from https://gitlab.winehq.org/wine/wine/-/blob/master/configure#L2552
  #? And https://gitlab.winehq.org/wine/wine/-/wikis/Building-Wine#satisfying-build-dependencies
  #? The ones with ? are mine.
  gettextSupport = false; # ?> "gettext tools not found (or too old), translations won't be built."
  fontconfigSupport = true; # Install if you want host fonts to be detected.
  alsaSupport = false; # the Alsa sound support
  gtkSupport = false;
  openglSupport = true; # OpenGL
  tlsSupport = true; # schannel support
  gstreamerSupport = false; # Multimedia playback. Generally necessary for apps that play back audio or video files.
  cupsSupport = false; # Install only if you need printer support.
  dbusSupport = true; # Dynamic device detection (specifically, mass storage)
  openclSupport = false; # OpenCL
  cairoSupport = true; # ? Graphics library
  odbcSupport = false; # ? ODBC (database) support
  netapiSupport = false; # the Samba NetAPI library
  cursesSupport = false; # * since-removed backend for wineconsole to create from existing terminal
  vaSupport = true; # ? VA-API video acceleration
  pcapSupport = true; # Install if you are using apps that require packet capture. (Replaces native wpcap.dll)
  v4lSupport = true; # Install only if you're capturing video.
  saneSupport = false; # Install only if you're using scanner/still image software.
  gphoto2Support = true; # ? ^^^ digital camera support
  krb5Support = true; # Install only if you're connecting via Kerberos.
  pulseaudioSupport = true; # Sound backend. At least one is necessary.
  udevSupport = true; # udev (plug and play support)
  xineramaSupport = false; # legacy multi-monitor support
  vulkanSupport = true; # Hardware-accelerated/3D graphics
  sdlSupport = false; # HID joystick support
  usbSupport = true; # Direct USB device support. Note that many apps using USB devices do so through HID.
  mingwSupport = false; # for Darwin
  waylandSupport = true; # the Wayland driver, ? including OpenGL support via wayland_egl
  x11Support = false; # ?> "Wine will be built without X support, which probably ~isn't~ IS what you want."
  ffmpegSupport = true; # ? "New Media Foundation backend using FFMpeg" introduced in 9.18
  embedInstallers = false; # The Mono and Gecko MSI installers

}).overrideAttrs
  (old: {
    configureFlags = old.configureFlags ++ [
      "--disable-tests"
    ];
  })
