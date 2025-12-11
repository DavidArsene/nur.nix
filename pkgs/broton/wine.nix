{ wine }:

# TODO: 11.0-rc1
wine.override {
  wineRelease = "staging"; # TODO: and tkg with .cfg
  wineBuild = "wine64";

  #? Descriptions from https://gitlab.winehq.org/wine/wine/-/blob/master/configure#L2552
  #? The ones with ? are mine.
  gettextSupport = false; # ?> "gettext tools not found (or too old), translations won't be built."
  fontconfigSupport = true; # ? used for FreeType fonts
  alsaSupport = false; # the Alsa sound support
  gtkSupport = false;
  openglSupport = true; # OpenGL
  tlsSupport = true; # schannel support
  gstreamerSupport = false; # codecs support
  cupsSupport = false; # CUPS
  dbusSupport = true; # dynamic device support
  openclSupport = false; # OpenCL
  cairoSupport = true; # ? Graphics library
  odbcSupport = false;
  netapiSupport = false; # the Samba NetAPI library
  cursesSupport = false; # * Removed backend for wineconsole to create from existing terminal
  vaSupport = true; # ? VA-API video acceleration
  pcapSupport = false; # the Packet Capture library
  v4lSupport = true; # v4l2 (video capture)
  saneSupport = false; # SANE (scanner support)
  gphoto2Support = true; # Digital Camera support
  krb5Support = true; # ?> "no Kerberos support, expect problems"
  pulseaudioSupport = true; # ? Expects at least one driver from [pulse,alsa,oss,coreaudio]
  udevSupport = true; # udev (plug and play support)
  xineramaSupport = false; # legacy multi-monitor support
  vulkanSupport = true;
  sdlSupport = true; # ? SDL2 graphics library
  usbSupport = true; # libusb
  mingwSupport = false; # for Darwin
  waylandSupport = true; # the Wayland driver
  x11Support = false;
  ffmpegSupport = true; # ? "New Media Foundation backend using FFMpeg" in 9.18
  embedInstallers = false; # The Mono and Gecko MSI installers
}
#Kerberos SSP support gss???
