{
  description = "An IDE assembled from smaller Unix programs, namely Zellij, Kakoune, Broot, Lazygit, and more";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # Sources
    zjstatus-source = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kakoune-source = {
      url = "github:mawww/kakoune";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, zjstatus-source, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # vide = pkgs.callPackage ./vide.nix {};
        kakoune = pkgs.kakoune;
        broot = pkgs.broot;
        lazygit = pkgs.lazygit;
        zjstatus = zjstatus-source.packages.${system}.default;


        '';
        layout = pkgs.substituteAll {
          name = "vide-layout.kdl";
          src = ./layout.kdl;
          git = "${git}/bin/git";
          zjstatus = "${zjstatus}/bin/zjstatus.wasm";
          broot = "${broot}/bin/broot";
          lazygit = "${lazygit}/bin/lazygit";
          kakouneStartup = "${kakoune-startup}";
        };
        vide = pkgs.writeShellScriptBin "vide" ''
          ${pkgs.zellij}/bin/zellij --layout ${layout}
        '';
      in {
        apps.default = {
          type = "app";
          program = "${vide}/bin/vide";
        };

        packages.default = vide;
        packages.vide = vide;
      });
}
