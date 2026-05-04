{ fetchFromGitHub, lenovo-legion, ... }:

lenovo-legion.overrideAttrs {
  version = "0.0.21-unstable-2025-12-19";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "johnfanv2";
    repo = "LenovoLegionLinux";
    rev = "1d9450ff9e7479ab3d15c0b15c312f16b3bea149";
    hash = "sha256-WXGDlfkH6aBUVotmDcGZ8Y/zC8iBAv57u3hXRnfTaSo=";
  };
}
