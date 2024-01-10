{ stdenv
, lib
, writeShellScript
, makeWrapper

, config
, programs
, components
}:

stdenv.mkDerivation rec {
  pname = "vide";
  version = "0.1.0";

  src = writeShellScript "vide" ''
      export KAKOUNE_CONFIG_DIR="${config.kakoune}"
      session_name=`${components.sessionNameGenerator}`
      export KKS_SESSION="$session_name"
      export KKS_CLIENT="main"
      export EDITOR="${components.editorOpen}"
      case `${programs.zellij} list-sessions --no-formatting --short` in
          *"$session_name"*)
              session_args="attach $session_name";;
          *)
              session_args="--session $session_name";;
      esac
      cmd="${programs.zellij} --config-dir ${config.zellij} $session_args"
      echo editor: $EDITOR
      echo cmd: $cmd
      if [ -t 0 ]; then
        eval $cmd
      else
        ${programs.alacritty} --command $SHELL -c "$cmd"
      fi
    export LG_CONFIG_FILE="${config.lazygit}/config.yml"
  '';

  nativeBuildInputs = [ makeWrapper ];

  dontUnpack = true;

  installPhase =
    lib.optionalString stdenv.isDarwin ''
      mkdir -p $out/bin
      cp "${src}" "$out/bin/${pname}"
      chmod +x "$out/bin/${pname}"
      mkdir -p "$out/Applications/${pname}.app/Contents/MacOS"
      makeWrapper "${src}" "$out/Applications/${pname}.app/Contents/MacOS/${pname}"
      mkdir -p "$out/Applications/${pname}.app/Contents/Resources"
      cp "${./icon/icon.icns}" "$out/Applications/${pname}.app/Contents/Resources/${pname}.icns"
      cp "${./Info.plist}" "$out/Applications/${pname}.app/Contents/Info.plist"
    '';      

  meta = with lib; {
    description = "A IDE made out of UNIX programs";
    homepage = "https://github.com/felko/vide";
    mainProgram = "vide";
    platforms = platforms.unix;
  };
}

