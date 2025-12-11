{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  extraPlugins = [
    "android"
    "android-apk"
    "android-compose-ide-plugin"
    #    "android-ndk" maybe fix lldb
    "c"
    "cidr-base"
    "cidr-clangd"
    "cidr-debugger"
    # "compose-ide-plugin"
    # "configurationScript"
    # "copyright"
    "design-tools"
    # "dev"
    "directaccess"
    # "editorconfig-plugin"
    #    "firebase"
    #    "firebase-testing"
    #    "gemini" by unpouplar request
    "git4insights"
    # "gradle"
    # ! "gradle-declarative" # ! wat?
    # "gradle-java"
    # "Groovy"
    # "html-tools"
    # "java"
    # "java-*"
    # "json"
    # "junit"
    # "keymap-*"
    # "Kotlin"
    # "markdown"
    # "performanceTesting"
    # "platform-images"
    # "platform-langInjection"
    # "properties"
    # "repository-search"
    # "sh"
    "smali"
    "targetsdkversion-upgrade-assistant"
    # "tasks"
    # "terminal"
    "test-recorder"
    # "testng"
    # "textmate"
    # "toml"
    "url-assistant"
    # "vcs-*"
    # "webp"
    # "yaml"
  ];
in

stdenv.mkDerivation rec {
  pname = "android-studio-plugins";

  version = "2025.2.1.5";
  buildNumber = "252.26830.84";

  dontUnpack = true;
  src = fetchurl {
    url = "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${version}/android-studio-${version}-linux.tar.gz";
    hash = "sha256-SlSuihfWQn8H0kUDJBMvWTkSecaxCU3gL3PkCN61ojw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
}
