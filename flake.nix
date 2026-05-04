{
  outputs =
    { self, nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    with nixpkgs.lib;
    {

      # callPackage is a special call which adds a so-called
      # "scope" to the package function call, which is where
      # the magic arguments passed to derivations come from.
      # The default one from `nixpkgs` adds all `pkgs`, and
      # with `newScope` used in ${directory}, all its ----
      # packages are appended to the search path as well.
      packages = packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage newScope;
        directory = ./pkgs;
      };

      nixosModules = concatMapAttrs (name: _: {
        "${removeSuffix ".nix" name}" = import ./nixosModules/${name};
      }) (builtins.readDir ./nixosModules);

      # TODO: STDENV DEFAULT
      stripDebugFlags = [
        "--preserve-dates"
        "--strip-unneeded"
      ];
    };
}
