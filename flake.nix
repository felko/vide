{
  description = "An IDE assembled from smaller Unix programs, namely Zellij, Kakoune, Broot, Lazygit, and more";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    # sources
    zjstatus-source = {
      url = "github:dj95/zjstatus";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kks-source = {
      url = "github:kkga/kks";
      flake = false;
    };

    alacritty-source = {
      url = "github:alacritty/alacritty/2786683e0ebba6b58f7246ba0f2e4b0a6b9679b2";
      flake = false;
    };

    kak-lsp-source = {
      url = "github:kak-lsp/kak-lsp";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib // import ./nix/lib.nix { inherit pkgs; };

        config = {
          kakoune = lib.substituteComponentsRecursively {
            name = "vide-kakoune-config";
            dir = ./kak;
            inherit components;
          };
          zellij = lib.substituteComponentsRecursively {
            name = "vide-zellij-config";
            dir = ./zellij;
            inherit components;
          };
          lazygit = lib.substituteComponentsRecursively {
            name = "vide-lazygit-config";
            dir = ./lazygit;
            inherit components;
          };
          yazi = lib.substituteComponentsRecursively {
            name = "vide-yazi-config";
            dir = ./yazi;
            inherit components;
          };
        };

        programs =
          let
            kks = pkgs.callPackage ./nix/kks.nix { src = inputs.kks-source; };

            alacritty = pkgs.callPackage ./nix/alacritty.nix {
              src = inputs.alacritty-source;
              inherit (pkgs.darwin.apple_sdk.frameworks) AppKit CoreGraphics CoreServices CoreText Foundation OpenGL;
            };

            kak-lsp = pkgs.callPackage ./nix/kak-lsp.nix {
              src = inputs.kak-lsp-source;
              inherit (pkgs.darwin.apple_sdk.frameworks) CoreServices Security SystemConfiguration;
            };

            substituteBroot = conf: components:
              let
                substitutedConf = lib.substituteComponents {
                  name = "vide-broot-config-${builtins.baseNameOf conf}";
                  src = conf;
                  components = components // {
                    brootCommonConfig = ./broot/common.hjson;
                  };
                };
              in
                pkgs.writeShellScript "vide-broot-${lib.stripFileExtension conf}.sh" ''
                  ${lib.getExe pkgs.broot} --conf ${substitutedConf} "$@"
                '';
          in {
            alacritty = lib.getExe alacritty;
            git = lib.getExe pkgs.git;
            zellij = lib.getExe pkgs.zellij;
            kak = lib.getExe pkgs.kakoune;
            broot-select-file = substituteBroot ./broot/select-file.hjson {};
            broot-select-directory = substituteBroot ./broot/select-directory.hjson {};
            lazygit = lib.getExe pkgs.lazygit;
            kks = lib.getExe kks;
            kak-lsp = lib.getExe kak-lsp;
            fzf = lib.getExe pkgs.fzf;
            zjstatus = "${inputs.zjstatus-source.packages.${system}.default}/bin/zjstatus.wasm";
            shell = lib.getExe pkgs.fish;
            yazi = lib.getExe pkgs.yazi;
          };
        
        components =
          let
            substituteScript = file: components:
              lib.substituteComponents {
                name = "vide-${builtins.baseNameOf file}";
                src = file;
                isExecutable = true;
                inherit components;
              };
          in rec {
            sessionNameGenerator = substituteScript ./bin/session-name-generator.sh {};
            editorStartup = substituteScript ./bin/editor-startup.sh {
              inherit sessionNameGenerator;
              inherit (programs) kak;
            };
            editorOpen = substituteScript ./bin/editor-open.sh {
              inherit sessionNameGenerator;
              inherit (programs) zellij kks;
            };
            selectFile = substituteScript ./bin/select-file.sh {
              inherit (programs) kks;
              brootSelectFile = programs.broot-select-file;
            };
            selectDirectory = substituteScript ./bin/select-directory.sh {
              inherit (programs) kks;
              brootSelectFile = programs.broot-select-directory;
            };
            selectAnything = substituteScript ./bin/select-anything.sh {
              inherit (programs) fzf;
            };
            selectBuffer = substituteScript ./bin/select-buffer.sh {
              inherit (programs) fzf kks;
            };
            scrollbackEditor = editorOpen;
            copyCommand = with pkgs;
              if stdenv.isDarwin then
                "pbcopy"
              else
                "${lib.getExe xsel} -i -b";
            pasteCommand = with pkgs;
              if stdenv.isDarwin then
                "pbpaste"
              else
                "${lib.getExe xsel} -o -b";
            inherit (programs) git zjstatus shell zellij kak kks lazygit yazi;
            kaklsp = programs.kak-lsp;
            fileExplorer = programs.yazi;
            vcsClient = substituteScript ./bin/vcs-client.sh {
              inherit (programs) lazygit;
            };
          };

        vide = pkgs.callPackage ./nix/vide.nix {
          inherit components programs config;
        };
      in {
        apps.default = {
          type = "app";
          program = "${vide}/bin/vide";
        };

        devShell = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.rnix-lsp ];
        };

        packages.default = vide;
        packages.vide = vide;
      });
}
