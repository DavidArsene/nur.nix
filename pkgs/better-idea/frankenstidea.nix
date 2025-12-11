{ stdenvNoCC, lib }:
with lib;
stdenvNoCC.mkDerivation rec {
  pname = "frankenstidea";
  version = "2025.3-1";

  meta = {
    homepage = "https://www.jetbrains.com/idea/";
    description = "Unofficial Frankenstein IDE combining features from various JetBrains IDEs";
    teams = [ teams.jetbrains ];
    license = licenses.unfree;
    sourceProvenance = [ sourceTypes.binaryBytecode ];
  };

}
