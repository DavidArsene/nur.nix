{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    inputs: with inputs; {
      packages = nixpkgs.lib.filesystem.packagesFromDirectoryRecursive {
        inherit (nixpkgs) callPackage;
        directory = ./pkgs;
      };
    };
}
