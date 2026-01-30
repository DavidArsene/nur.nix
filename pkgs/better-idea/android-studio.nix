{
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
ex2 = {
        "com.intellij.cidr.base": false,
        "com.intellij.cidr.debugger": false,
        "com.intellij.cidr.lang": false,
        "com.intellij.cidr.lang.clangd": false,
        "com.intellij.compose": false,
        "com.intellij.java.ide": false,
        "com.intellij.platform.images": false,
        "com.jetbrains.performancePlugin": false,
        "org.intellij.groovy": false,
        "org.intellij.plugins.markdown": false,
        "org.jetbrains.debugger.streams": false,
        "org.jetbrains.java.decompiler": false,
        "org.jetbrains.plugins.textmate": false,
        "com.android.tools.apk": false,
        "com.android.tools.ndk": false,
        "com.google.services.git4insights": false,
        "com.google.services.firebase": false,
        "com.google.gct.directaccess": false,
        "com.google.gct.testing": false,
        "com.google.gct.test.recorder": false,
        "com.google.urlassistant": false,
        "com.google.targetsdkversionassistant": false,
        "com.android.tools.gradle.dcl": false,
        "com.android.tools.gradle.dsl": false
      };

      {
        "Coverage": true,
        "Git4Idea": false,
        "HtmlTools": true,
        "JUnit": true,
        "Subversion": true,
        "TestNG-J": true,
        "com.intellij": false,
        "com.intellij.cidr.base": false,
        "com.intellij.cidr.debugger": false,
        "com.intellij.cidr.lang": false,
        "com.intellij.cidr.lang.clangd": false,
        "com.intellij.completion.ml.ranking": true,
        "com.intellij.compose": false,
        "com.intellij.configurationScript": true,
        "com.intellij.copyright": true,
        "com.intellij.dev": true,
        "com.intellij.gradle": true,
        "com.intellij.java": true,
        "com.intellij.java-i18n": true,
        "com.intellij.java.ide": false,
        "com.intellij.modules.json": true,
        "com.intellij.platform.images": false,
        "com.intellij.plugins.eclipsekeymap": true,
        "com.intellij.plugins.netbeanskeymap": true,
        "com.intellij.plugins.visualstudiokeymap": true,
        "com.intellij.properties": true,
        "com.intellij.tasks": true,
        "com.intellij.turboComplete": true,
        "com.jetbrains.performancePlugin": false,
        "com.jetbrains.sh": true,
        "hg4idea": true,
        "intellij.git.commit.modal": true,
        "intellij.webp": true,
        "org.editorconfig.editorconfigjetbrains": true,
        "org.intellij.groovy": false,
        "org.intellij.plugins.markdown": false,
        "org.jetbrains.debugger.streams": false,
        "org.jetbrains.idea.reposearch": true,
        "org.jetbrains.java.decompiler": false,
        "org.jetbrains.kotlin": true,
        "org.jetbrains.plugins.github": true,
        "org.jetbrains.plugins.gitlab": true,
        "org.jetbrains.plugins.gradle": true,
        "org.jetbrains.plugins.terminal": true,
        "org.jetbrains.plugins.textmate": false,
        "org.jetbrains.plugins.yaml": true,
        "org.toml.lang": true,
        "tanvd.grazi": true,
        "org.jetbrains.android": true,
        "com.android.tools.apk": false,
        "com.android.tools.ndk": false,
        "com.android.tools.design": true,
        "androidx.compose.plugins.idea": true,
        "com.google.services.git4insights": false,
        "com.google.services.firebase": false,
        "com.google.tools.ij.aiplugin": true,
        "com.google.gct.directaccess": false,
        "com.google.gct.testing": false,
        "com.android.tools.idea.smali": true,
        "com.google.gct.test.recorder": false,
        "com.google.urlassistant": false,
        "com.google.targetsdkversionassistant": false,
        "com.android.tools.gradle.dcl": false,
        "com.android.tools.gradle.dsl": false
      }

  # ! Take android and design-tools from here maybe because smaller size since platform-specific builds
  # ! but needs gradle dsl which conflicts with regular ij one
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
