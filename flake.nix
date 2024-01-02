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
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, zjstatus-source, kks-source, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib // import ./lib.nix { inherit pkgs; };

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
        };

        programs =
          let
            kks = pkgs.buildGoModule rec {
              pname = "kks";
              version = "v0.3.8";
              src = kks-source;

              vendorHash = "sha256-E4D9FGTpS9NkZy6tmnuI/F4dnO9bv8MVaRstxVPvEfo=";
              subPackages = [ "." ];

              ldflags = [ "-X main.version=${version}" "-X main.buildSource=nix" ];

              postInstall = ''
                install -Dm555 scripts/kks-* -t $out/bin
              '';

              meta = {
                mainProgram = "kks";
              };
            };

            broot = conf: pkgs.writeShellScript "vide-broot-${lib.stripFileExtension conf}.sh" ''
              ${lib.getExe pkgs.broot} --conf ${conf} $@
            '';
            substituteBroot = conf: components:
              let
                substitutedConf = lib.substituteComponents {
                  name = "vide-broot-config-${builtins.baseNameOf conf}";
									src = conf;
									inherit components;
                };
              in
              	pkgs.writeShellScript "vide-broot-${lib.stripFileExtension conf}.sh" ''
                  ${lib.getExe pkgs.broot} --conf ${substitutedConf} $@
                '';
          in {
            git = lib.getExe pkgs.git;
            zellij = lib.getExe pkgs.zellij;
            kak = lib.getExe pkgs.kakoune;
            broot-select-file = broot ./broot/select-file.toml;
            broot-select-directory = broot ./broot/select-directory.toml;
            broot-file-explorer = substituteBroot ./broot/file-explorer.toml { inherit (programs) kks; };
            lazygit = lib.getExe pkgs.lazygit;
            kks = lib.getExe kks;
            fzf = lib.getExe pkgs.fzf;
            zjstatus = "${zjstatus-source.packages.${system}.default}/bin/zjstatus.wasm";
            shell = lib.getExe pkgs.fish;
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
            selectFile = substituteScript ./bin/select-file.sh {
              inherit (programs) kks;
              brootSelectFile = programs.broot-select-file;
            };
            selectDirectory = substituteScript ./bin/select-directory.sh {
              inherit (programs) kks;
              brootSelectDirectory = programs.broot-select-directory;
            };
            selectBuffer = substituteScript ./bin/select-buffer.sh {
              inherit (programs) fzf kks;
            };
            scrollbackEditor = substituteScript ./bin/edit.sh {
              inherit sessionNameGenerator;
              inherit (programs) kks;
            };
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
            inherit (programs) git zjstatus shell zellij kak kks;
            fileExplorer = programs.broot-file-explorer;
            vcsClient = programs.lazygit;
          };

        # kakoune-theme = pkgs.substituteAll {
        # 	name = "vide-theme.kak";
        #   src = ./theme.kak;
 	      # };
        vide = pkgs.writeShellScriptBin "vide" ''
          export KAKOUNE_CONFIG_DIR="${config.kakoune}"
          session_name="$(${components.sessionNameGenerator})"
          export KKS_SESSION="$(${components.sessionNameGenerator})"
          case "$(${programs.zellij} list-sessions --no-formatting --short)" in
              *"$session_name"*)
                  session_args="attach $session_name";;
              *)
                  session_args="--session $session_name";;
          esac
          ${programs.zellij} --config-dir "${config.zellij}" $session_args
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
