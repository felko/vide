{ pkgs, ... }:

with pkgs;
with lib;
rec {
  slugifyPath = str:
    let
      components = builtins.tail (lib.strings.splitString "/" str);
    in
      builtins.concatStringsSep "-" components;

  stripFileExtension = path:
    let
    	baseName = builtins.baseNameOf path;
    	split = lib.strings.split "\\." baseName;
    in
      builtins.elemAt split 0;
      
  substituteComponents = args @ { components, ... }:
    substituteAll ((builtins.removeAttrs args ["components"]) // components);

  substituteComponentsRecursively = { name, components, dir }:
    let
      files = lib.filesystem.listFilesRecursive dir;
      relPath = file: lib.path.removePrefix dir (builtins.dirOf file);
      substituteToRelPath = file: substituteComponents {
        name = builtins.baseNameOf file;
        inherit components;
        src = file;
        dir = relPath file;
      };
    in
      symlinkJoin {
        inherit name;
        paths = builtins.map substituteToRelPath files;
      };
}
