let
  pkgs = import <nixpkgs> { system = "aarch64-darwin"; };
  lib = pkgs.lib;
  vlib = import ./lib.nix { inherit pkgs; };
  components = {
    copyCommand = "pbcopy";
  };
in
  vlib.substituteComponentsRecursively {
    name = "vide-zellij";
    inherit components;
    dir = ./zellij;
  }
