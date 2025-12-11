{ lib, fetchurl }:
let
  join = lib.concatStringsSep;

  # TODO: spaces in filenames
  directoryStructureToList =
    with lib;
    mapAttrsToListRecursive (
      path: val:
      let
        toPath = leaf: join "/" (path ++ [ leaf ]);
        leaves = if isList val then val else [ (if val == true then "" else val) ];
      in
      # map is for leaf lists, which will be turned into a space-delimited string.
      # so this thing outputs a list of strings, some representing one path,
      # some multiple. Should be joined again later.
      concatMapStringsSep " " toPath leaves
    );
in

# Adapted from pkgs.fetchzip
lib.extendMkDerivation {

  constructDrv = fetchurl;

  extendDrvArgs =
    finalAttrs:
    {
      # TODO: downloadToTemp ? true,

      # Can probably be left empty, I didn't try
      rootDir ? "missing-root-dir",

      # Directory structure of inclusions.
      # Leave empty to include everything.
      # Use { attrs } for subdirectories.
      #
      # Paths can be finished with either:
      # - true: include entire directory
      # - "name": include this subdirectory
      # - [ ".", ".." ]: include selectively
      includeMap ? {
        "bin" = "idea";
        "lib" = "";
        "modules" = [
          "JavaScriptLanguage"
          "Kotlin"
        ];
      },
      # Directory structure of exclusions.
      # Parent directories will be automatically included.
      # e.g., "root/subdir/file" will include "root/subdir".
      # It is understandable that to exclude something,
      # it has to be included first. Note that intermediary
      # directories will NOT be included.
      #
      # Otherwise functions exactly like includeMap.
      excludeMap ? {
        "plugins" = {
          "git" = [
            "git4idea"
            "GitHub"
          ];
          "hub" = true;
        };
      },

      # Literal string that will be passed to tar.
      # Defaults to turning the maps into a corresponding
      # directory structures, relative to rootDir.
      finalExcludeList ? directoryStructureToList excludeMap,
      finalIncludeList ? directoryStructureToList (
        # add excludeMap but with all leaves removed
        #    (lib.mapAttrsRecursive (path: val: true) excludeMap) // includeMap
        (
          set:
          let
            recurse =
              path:
              lib.mapAttrs (name: value: (if lib.isAttrs value then recurse (path ++ [ name ]) else path) value);
          in
          recurse [ ] set
        )
          (path: val: true)
          excludeMap
        // includeMap
      ),

      # the rest are given to fetchurl as is
      ...
    }@args:
    {
      recursiveHash = true;

      downloadToTemp = true;

      postFetch = ''
        mkdir -p $out

        tar --wildcards \
        --directory $out \
        --extract  --gzip \
        -f $downloadedFile \
        --show-omitted-dirs \
        --strip-components=1 \
        --exclude-from <(

          tr " " '\n' <<< '${rootDir}'/{'${join "','" finalExcludeList}'}

        ) '${rootDir}'/{'${join "','" finalIncludeList}'}
      ''; # expand to add rootDir, single-quote to preserve wildcards
    };

  excludeDrvArgNames = [
    # TODO: Move these arguments to derivationArgs when available.

    "rootDir"
    "includeMap"
    "excludeMap"
    "finalExcludeList"
    "finalIncludeList"
  ];
}

#  phases = [
#    "unpackPhase"
#    "fixupPhase"
#  ];
