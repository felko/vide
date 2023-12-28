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
        layout = pkgs.writeText "layout.kdl" ''
          layout {
              default_tab_template {
                  children

                  pane size=1 borderless=true {
                      plugin location="file:${zjstatus}/bin/zjstatus.wasm" {
                          format_left  "{mode} #[fg=#89B4FA,bold] {tabs}"
                          format_right "{command_git_branch} {session}"
                          format_space ""

                          border_enabled  "false"
                          border_char     "─"
                          border_format   "#[fg=#6C7086]{char}"
                          border_position "top"

                          hide_frame_for_single_pane "true"

                          mode_normal       "#[bg=#89B4FA] {name} "
                          mode_locked       "#[bg=#89B4FA] {name} "
                          mode_resize       "#[bg=#89B4FA] {name} "
                          mode_pane         "#[bg=#89B4FA] {name} "
                          mode_tab          "#[bg=#89B4FA] {name} "
                          mode_scroll       "#[bg=#89B4FA] {name} "
                          mode_enter_search "#[bg=#89B4FA] {name} "
                          mode_search       "#[bg=#89B4FA] {name} "
                          mode_rename_tab   "#[bg=#89B4FA] {name} "
                          mode_rename_pane  "#[bg=#89B4FA] {name} "
                          mode_session      "#[bg=#89B4FA] {name} "
                          mode_move         "#[bg=#89B4FA] {name} "
                          mode_prompt       "#[bg=#89B4FA] {name} "
                          mode_tmux         "#[bg=#ffc387] {name} "

                          tab_normal   "#[fg=#6C7086] {name} "
                          tab_active   "#[fg=#9399B2,bold,italic] {name} "

                          command_git_branch_command     "git rev-parse --abbrev-ref HEAD"
                          command_git_branch_format      "#[fg=blue] {stdout} "
                          command_git_branch_interval    "10"
                          command_git_branch_rendermode  "static"
                      }
                  }
              }
              
              tab name="file" {
                  pane name="main" command="${broot}/bin/broot"
              }
              tab name="edit" focus=true {
                  pane split_direction="vertical" {
                      pane name="main" command="${kakoune}/bin/kak" size="61%"
                      pane name="term"
                  }
              }
              tab name="git" {
                  pane name="main" command="${lazygit}/bin/lazygit"
              }
          }
        '';
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
