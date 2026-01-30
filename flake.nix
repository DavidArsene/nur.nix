{
  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    rec {

      # callPackage is a special call which adds a so-called
      # "scope" to the package function call, which is where
      # the magic arguments passed to derivations come from.
      # The default one from `nixpkgs` adds all `pkgs`, and
      # with `newScope` used in ${directory}, all its ----
      # packages are appended to the search path as well.
      packages = pkgs.lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage newScope;
        directory = ./pkgs;
      };

      nixosModules = {
        fprintd-fpc = import ./nixosModules/fprintd-fpc.nix;
        ro-cei-pcsc = import ./nixosModules/ro-cei-pcsc.nix;
      };

      legacyPackages.${system} = packages;

      # TODO: STDENV DEFAULT
      stripDebugFlags = [
        "--preserve-dates"
        "--strip-unneeded"
      ];
    };
}
