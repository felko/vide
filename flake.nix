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

    kks-source = {
      url = "github:kkga/kks";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, zjstatus-source, kks-source, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        git = pkgs.git;
        zellij = pkgs.zellij;
        kakoune = pkgs.kakoune;
        broot = pkgs.broot;
        lazygit = pkgs.lazygit;
        kks = with pkgs; with lib;
          buildGoModule rec {
            pname = "kks";
            version = "v0.3.8";
            src = kks-source;

            vendorHash = "sha256-E4D9FGTpS9NkZy6tmnuI/F4dnO9bv8MVaRstxVPvEfo=";
            subPackages = [ "." ];

            ldflags = [ "-X main.version=${version}" "-X main.buildSource=nix" ];

            postInstall = ''
              install -Dm555 scripts/kks-* -t $out/bin
            '';
          };

				fzf = pkgs.fzf;
        zjstatus = zjstatus-source.packages.${system}.default;

        kakoune-startup = pkgs.writeShellScript "vide-kakoune-startup.sh" ''
	  session_name="$(${session-name-generator})"
          case "$(kak -l)" in
              *"$session_name (dead)"*)
                  kak -clear
                  session_arg="-s $session_name";;
              *"$session_name"*)
                  session_arg="-c $session_name";;
              *)
                  session_arg="-s $session_name";;
          esac

          ${kakoune}/bin/kak -n $session_arg -e 'rename-client main' -E 'source ${kakoune-config}'
        '';
        select-file = pkgs.writeShellScript "vide-select-file.sh" ''
          selected="$(${broot}/bin/broot --conf ${./broot/select-file.toml})"
          if [ -n "$selected" ]; then
            echo evaluate-commands -client "$2" edit-or-buffer "$selected" | kak -p "$1"
          else
            echo evaluate-commands -client "$2" echo "no file selected" | kak -p "$1"
          fi
        '';
        select-directory = pkgs.writeShellScript "vide-select-directory.sh" ''
          selected="$(${broot}/bin/broot --conf ${./broot/select-directory.toml} --only-folders)"
          if [ -n "$selected" ]; then
            echo evaluate-commands -client "$2" change-directory "$selected" | kak -p "$1"
          else
            echo evaluate-commands -client "$2" echo "no directory selected" | kak -p "$1"
          fi
        '';
        select-buffer = pkgs.writeShellScript "vide-select-buffer.sh" ''
          selected="$(KKS_SESSION="$1" KKS_CLIENT="$2" ${kks}/bin/kks get %val{buflist} | ${fzf}/bin/fzf)"
          if [ -n "$selected" ]; then
            echo evaluate-commands -client "$2" buffer "$selected" | kak -p "$1"
          else
            echo evaluate-commands -client "$2" echo "no buffer selected" | kak -p "$1"
          fi
        '';
        kakouneTheme = pkgs.substituteAll {
	  name = "vide-theme.kak";
          src = ./theme.kak;
	};
        kakoune-config = pkgs.substituteAll {
          name = "vide.kak";
          src = ./vide.kak;
          selectFile = select-file;
          selectDirectory = select-directory;
          selectBuffer = select-buffer;
	        theme = kakouneTheme;
        };
        session-name-generator = pkgs.writeShellScript "vide-session-name-generator.sh" ''
          echo "$(basename $(pwd))" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-'
        '';
        layout = pkgs.substituteAll {
          name = "vide-layout.kdl";
          src = ./layout.kdl;
          git = "${git}/bin/git";
          zjstatus = "${zjstatus}/bin/zjstatus.wasm";

          fileExplorer = "${broot}/bin/broot";
          vcsClient = "${lazygit}/bin/lazygit";
          editorStartup = "${kakoune-startup}";
        };
        vide = pkgs.writeShellScriptBin "vide" ''
          session_name="$(${session-name-generator})"
          case "$(${zellij}/bin/zellij list-sessions --no-formatting --short)" in
              *"$session_name"*)
                  session_args="attach $session_name";;
              *)
                  session_args="--session $session_name --layout ${layout}";;
          esac
          ${zellij}/bin/zellij $session_args
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
